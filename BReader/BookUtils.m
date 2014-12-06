//
//  BookUtils.m
//  BReader
//
//  Created by ruikye on 14-3-29.
//
//

#import "BookUtils.h"
#import "RegexKitLite.h"
#include "sys/stat.h"
#include "stdio.h"
#include "wchar.h"
#include "TypeSetter.h"

static NSString* CHAPTER_REGEX = @"^\\s{0,}第[〇一二三四五六七八九十百千零0123456789]+[章卷篇节集回].*$";
static NSString* EXCEPTION_FILE_NOT_EXIST = @"EXCEPTION_FILE_NOT_EXIST";
static NSString* EXCEPTION_UNRECOGNIZE_CONTENT = @"EXCEPTION_UNRECOGNIZE_CONTENT";
static NSString* EXCEPTION_UNSUPPORT_FILE_TYPE = @"EXCEPTION_UNSUPPORT_FILE_TYPE";
static NSString* EXCEPTION_UNSUPPORT_FILE_ENCODING = @"EXCEPTION_UNSUPPORT_FILE_ENCODING";
static NSString* EXCEPTION_IS_FIRST_PAGE = @"EXCEPTION_IS_FIRST_PAGE";
static NSString* EXCEPTION_IS_LAST_PAGE = @"EXCEPTION_IS_LAST_PAGE";
static NSString* EXCEPTION_BUILD_CACHE_ERROR = @"EXCEPTION_BUILD_CACHE_ERROR";
static NSString* ENCODING_STR[] = {@"ANSI",@"UTF-8",@"UNICODE",@"UNICODE_BIG"};

#pragma implementation for class Catalog
@implementation Catalog
@synthesize name, position;
- (void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:position] forKey:@"_catalog_position_"];
    [encoder encodeObject:name forKey:@"_catalog_name_"];
}

-(id) initWithCoder:(NSCoder *)encoder{
    if (self = [self init]) {
        self.position = [[encoder decodeObjectForKey:@"_catalog_position_"] unsignedIntegerValue];
        self.name = [encoder decodeObjectForKey:@"_catalog_name_"];
    }
    return self;
}

@end

#pragma implementation for class BEXCEPTION
@implementation BEXCEPTION
+(NSString*) Loader_IsFirstPageException{return EXCEPTION_IS_FIRST_PAGE;}
+(NSString*) Loader_IsLastPagException{return EXCEPTION_IS_LAST_PAGE;}
+(NSString*) Loader_BuildCacheException{return EXCEPTION_BUILD_CACHE_ERROR;}
+(NSString*) unsupportTypeException{return EXCEPTION_UNSUPPORT_FILE_TYPE;}
+(NSString*) unsupportEncodingException{return EXCEPTION_UNSUPPORT_FILE_ENCODING;}
@end

@implementation NSString (StringUtil)
-(instancetype) trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL) endWithNewLine{
    return [[self reverse] startWithNewLine];
}

-(BOOL) startWithNewLine{
    NSString* tmp = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return tmp.length !=0 && [tmp characterAtIndex:0]=='\r';
}

-(instancetype) reverse{
    NSUInteger len = [self length];
    wchar_t* buf = (wchar_t*)[self cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    wchar_t tmp;
    for(int i=0; len-i-1>i; ++i){
        tmp = buf[i];
        buf[i] = buf[len-i-1];
        buf[len-i-1] = tmp;
    }
    return [[NSString alloc] initWithBytes:buf length:sizeof(wchar_t)*len encoding:NSUTF32LittleEndianStringEncoding];
}

-(NSInteger) countSubString:(NSString *)sub{
    if (sub == nil || sub.length <= 0) {return -1;}
    NSString* src = [NSString stringWithString:self];
    NSRange range = [src rangeOfString:sub];
    NSInteger count = 0;
    while (range.location!=NSNotFound) {
        count++;
        src = [src substringFromIndex:range.location+range.length];
        range = [src rangeOfString:sub];
    }
    return count;
}

@end

#pragma implementation for class page
@implementation Page
@synthesize string, range, startWithNewLine;
-(id) initWithString:(NSString *)str encoding:(NSStringEncoding)encoding{
    self = [self init];
    if (self) {
        self.string           = str;
        self.range            = NSMakeRange(0, [str lengthOfBytesUsingEncoding:encoding]);
        self.startWithNewLine = [str characterAtIndex:0] == '\r';
    }
    return self;
}

-(NSUInteger) nextPosition{
    return range.location+range.length;
}
-(NSString*) description{
    return [NSString stringWithFormat:@"Rang(%lu,%lu)\n%@", (unsigned long)range.location, (unsigned long)range.length, string];
}
@end

#pragma implementation for class BookMark
@implementation BookMark
@synthesize position, name, time;

- (void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:position] forKey:@"_bookmark_position_"];
    [encoder encodeObject:name forKey:@"_bookmark_name_"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:time] forKey:@"_bookmark_time_"];
}

-(id) initWithCoder:(NSCoder *)encoder{
    if (self == [self init]) {
        self.position = [[encoder decodeObjectForKey:@"_bookmark_position_"] unsignedIntegerValue];
        self.name = [encoder decodeObjectForKey:@"_bookmark_name_"];
        self.time = [[encoder decodeObjectForKey:@"_bookmark_time_"] unsignedIntegerValue];
    }
    return self;
}

-(NSString*) description{
    return [NSString stringWithFormat:@"Mark->{%@,%lu,%lu}", name, position, time];
}
@end

#pragma implementation for class Book
@implementation Book
@synthesize path, name, lastOpenTime, mark, size, type, encoding, catalog, fullPath;
+(Book*) forName:(NSString *)name{return [Book forName:name forType:[BookUtils getTypeOfFile:name]];}
+(Book*) forName:(NSString *)name forType:(BFileType)type{return [Book forName:name inPath:nil forType:type];}
+(Book*) forName:(NSString *)name inPath:(NSString *)path{return [Book forName:name inPath:path forType:[BookUtils getTypeOfFile:name]];}
+(Book*) forName:(NSString *)name inPath:(NSString *)path forType:(BFileType)type{
    NSString* fileName;
    if (path == nil) {fileName = name;}else{
        fileName = path;
        if (![path hasSuffix:@"/"]) { path = [path stringByAppendingString:@"/"];}
        fileName = [path stringByAppendingString:name];
    }

    NSString* fullName = name;
    name = [name reverse];
    NSRange range = [name rangeOfString:@"."];
    NSString* stype = [[name substringToIndex:range.location] reverse];
    name = [name substringFromIndex:range.location+1];
    name = [name reverse];

    if(type==UNKONW){[NSException raise:EXCEPTION_UNSUPPORT_FILE_TYPE format:@"Unkonw type for file: %@%@",path,name];}
    fileName = [[NSBundle mainBundle] pathForResource:name ofType:stype inDirectory:path];
    FILE* fp = fopen([fileName UTF8String], "r");
    if(fp==NULL){[NSException raise:EXCEPTION_FILE_NOT_EXIST format:@"file %@ not exsit!",fileName];}else{fclose(fp);}
    BEncoding encoding = [BookUtils getTxtEncoding:fileName];
    if(encoding==ERROR){[NSException raise:EXCEPTION_UNSUPPORT_FILE_ENCODING format:@"Unkonw encoding for file: %@", fileName];}

    Book* book    = [[Book alloc] init];
    book.type     = type;
    book.encoding = encoding;
    book.size     = (NSUInteger)[BookUtils getSizeWithBytes:fileName];
    book.path     = path;
    book.name     = fullName;
    book.fullPath = fileName;

    [book readBookMark];
    return book;
}

-(NSString*) simpleName{
    NSString* tmp = [name reverse];
    NSRange range = [tmp rangeOfString:@"."];
    if (range.location == NSNotFound || range.location == tmp.length-1) {
        return name;
    }
    return [[tmp substringFromIndex:range.location+1] reverse];
}

-(void) saveBookMark{
    NSData* _mark = [NSKeyedArchiver archivedDataWithRootObject:mark];
    [[NSUserDefaults standardUserDefaults] setObject:_mark forKey:[NSString stringWithFormat:@"_bookmark_for_%@", name]];
}

-(void) readBookMark{
    NSData* _mark = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"_bookmark_for_%@", name]];
    mark = [NSKeyedUnarchiver unarchiveObjectWithData:_mark];
    if (mark == nil) {
        mark = [[BookMark alloc] init];
    }
}

-(NSString*) description{
    return [NSString stringWithFormat:@"\nName:%@\nType:%@\nEncoding:%@\nPath:%@\nSize:%lld",
            name,[BookUtils getFileTypeString:type],[BookUtils getEncodingString:encoding],fullPath,size];
}
@end

#pragma implementation for class BookUtils
@implementation BookUtils
/** 获取指定文件{fileName}的长度 */
+(long long) getSizeWithBytes:(NSString*) fileName{
    struct stat st;
    return (lstat([fileName cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)?st.st_size:0;
}

+(Catalog*) extractCatalog:(NSString*)string position:(NSUInteger) position encoding:(NSStringEncoding) encoding{
    NSArray *lines = [string componentsSeparatedByString:@"\r"];
    Catalog* catalog;
    for (int i=0; i<lines.count; ++i) {
        NSString* line = (NSString*)[lines objectAtIndex:i];
        if ([line isMatchedByRegex:CHAPTER_REGEX]) {
            catalog = [[Catalog alloc] init];
            line = line.length > 24 ? [line substringToIndex:24]:line;
            catalog.name = [line trim];
            line = [string substringToIndex:[string rangeOfString:line].location];
            catalog.position = position + [line lengthOfBytesUsingEncoding:encoding];
            return catalog;
        }
    }
    return nil;
}

/** 读取指定文件{fileName}的章节目录 */
+(NSMutableArray*) getCatalog:(Book *)book{return [BookUtils getCatalog:book.fullPath encoding:book.encoding];}

+(NSMutableArray*) getCatalog:(NSString *)fileName encoding:(BEncoding) encoding{
    NSStringEncoding encoding_type = [BookUtils parseBEncoding:encoding];
    Catalog* catalog;
    NSMutableArray* array;

    if (encoding == UNICODE || encoding == UNICODE_BIG) {
        NSUInteger position = 0;
        long long size = [self getSizeWithBytes:fileName];
        Page* buf;
        @try {
            while (position < size) {
                buf = [self getPageInFile:fileName position:position length:2048 refLen:2048 dir:FORWORD encoding:encoding];
                if (buf==nil) { break; }
                catalog = [BookUtils extractCatalog:buf.string position:position encoding:encoding_type];
                if (catalog!=nil) {
                    if (array == nil) {
                        array=[[NSMutableArray alloc] init];
                    }

                    if (array.count==0 && catalog.position !=0) {
                        catalog.position = 0;
                    }

                    [array addObject:catalog];}
                position += buf.range.length;
            }
        }
        @catch (NSException *exception) {
            DLog(@"%@=>%@", [exception name], [exception reason]);
        }
        return array;
    } else {
        FILE* fp = fopen([fileName UTF8String], "r");
        NSUInteger lastPos = 0;
        if (fp == NULL){[NSException raise:EXCEPTION_FILE_NOT_EXIST format:@"file %@ not exsit!", fileName];}else{
            NSString* line;
            array = [[NSMutableArray alloc] init];
            char buf[256];
            while(fgets(buf, 256, fp)!=NULL) {
                line = [[NSString alloc] initWithBytes:buf length:sizeof(char)*strlen(buf) encoding:encoding_type];
                if ([line isMatchedByRegex:CHAPTER_REGEX]) {
                    line = line.length > 24 ? [line substringToIndex:24]:line;

                    if (array.count==0&&lastPos!=0) {
                        lastPos = 0;
                    }

                    catalog             = [[Catalog alloc] init];
                    catalog.name        = [line trim];
                    catalog.position    = lastPos;
                    [array addObject:catalog];
                }
                lastPos = ftell(fp);
            }
            fclose (fp);
            return array;
        }
    }
    return nil;
}

+(int) firstOffsetOfEncoding:(BEncoding)encoding{
    if (encoding == UNICODE || encoding == UNICODE_BIG) {
        return 2;
    } else if(encoding == UTF_8){
        return 3;
    }
    return 0;
}

+(BOOL) isBookHeader:(Catalog *)catalog{
    return catalog!=nil&&catalog.position==0&&[catalog.name compare:@"开篇"]==NSOrderedSame;
}

/*
 * 获取文件编码格式
 *
 * 原理：
 *   通过一个文件的最前面三个字节，可以判断出该的编码类型：
 *   ANSI：　　　　　　　　   无格式定义；(第一个字节开始就是文件内容)
 *   Unicode： 　　　　　　  前两个字节为FFFE；
 *   Unicode big endian：　前两字节为FEFF；
 *   UTF-8：　 　　　　　　  前两字节为EFBB，第三字节为BF
 */
+(BEncoding) getTxtEncoding:(NSString *)fileName{
    BEncoding type = ANSI;
    FILE *fp = fopen([fileName UTF8String], "r");
    if (fp != NULL) {
        unsigned char* buf = (unsigned char*)malloc(sizeof(unsigned char*)*3);
        fread(buf, sizeof(unsigned char), 3, fp);
        fclose(fp);
        if (buf[0] == 0xEF && buf[1] == 0xBB && buf[2] == 0xBF) {
            type = UTF_8;
        } else if(buf[0] == 0xFF && buf[1] == 0xFE) {
            type = UNICODE;
        } else if(buf[0] == 0xFE && buf[1] == 0xFF) {
            type = UNICODE_BIG;
        }
        free(buf);
    } else {[NSException raise:EXCEPTION_FILE_NOT_EXIST format:@"file %@ not exsit!", fileName];}
    return type;
}

+(NSStringEncoding) parseBEncoding:(BEncoding) encoding{
    NSStringEncoding encoding_type;
    if (encoding == UTF_8) {
        encoding_type = NSUTF8StringEncoding;
    } else if(encoding == UNICODE){
        encoding_type = NSUTF16LittleEndianStringEncoding;
    } else if(encoding == UNICODE_BIG){
        encoding_type = NSUTF16BigEndianStringEncoding;
    } else {
        encoding_type = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    return  encoding_type;
}

/** 从指定位置{position}按方向{dir}读取长度{bufLength}的内容 */
+(Page*) getPageInBook:(Book *)book position:(NSUInteger)position length:(NSUInteger)bufLength refLen:(NSUInteger) refLength dir:(BDirection)dir{
    return [BookUtils getPageInFile:book.fullPath position:position length:bufLength refLen:refLength dir:dir encoding:book.encoding];}
+(Page*) getPageInFile:(NSString*) fileName position:(NSUInteger)position length:(NSUInteger)bufLength refLen:(NSUInteger) refLength dir:(BDirection)dir encoding:(BEncoding) encoding{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileName];
    if (fileHandle == nil) {[NSException raise:EXCEPTION_FILE_NOT_EXIST format:@"file %@ not exsit!", fileName];}

    NSUInteger originalPos = position;
    if (position < refLength && dir == BACKWORD) {
        position = 0;
        dir = FORWORD;
    }

    if (position < bufLength && dir == BACKWORD) {
        bufLength = position;
    }

    int offset = 0;
    NSData* buf;
    NSString* bufString;
    NSUInteger originalBufLength = bufLength;
    NSStringEncoding encoding_type = [self parseBEncoding:encoding];
    do{
        if (offset>=2) {
            offset = 0;
            position++;
            bufLength = originalBufLength;
        }
        [fileHandle seekToFileOffset:position - dir * bufLength];
        buf = [fileHandle readDataOfLength:bufLength--];
        bufString = [[NSString alloc] initWithData:buf encoding:encoding_type];
        offset++;
    }while(bufString==nil||[bufString cStringUsingEncoding:NSUTF8StringEncoding]==NULL);
    if (bufString==nil) { [fileHandle closeFile]; return nil; }

    Page* page            = [[Page alloc] init];
    page.string           = bufString;
    page.range            = NSMakeRange(dir==BACKWORD?(position - originalBufLength):position, [buf length]);

    if (originalPos == 0) {
        page.startWithNewLine = YES;
    } else {
        bufLength         = 2;
        dir               = BACKWORD;
        NSString* tmp;
        do{
            [fileHandle seekToFileOffset:position - dir * bufLength];
            buf = [fileHandle readDataOfLength:bufLength++];
            tmp = [[NSString alloc] initWithData:buf encoding:encoding_type];
        }while([tmp description].length<=0);
        page.startWithNewLine = [tmp startWithNewLine];
    }
    [fileHandle closeFile];
    return page;
}

+(NSMutableArray*) pagingOfBook:(Book *)book byRange:(NSRange)range inRect:(CGRect)rect{
    if (book == nil) { return nil; }
    Page* original = [self getPageInBook:book position:range.location length:range.length refLen:range.length dir:FORWORD];
    if (original == nil) { return nil; }
    return [self pagingOfString:original.string inRect:rect encoding:book.encoding];
}

+(NSMutableArray*) pagingOfString:(NSString *)string inRect:(CGRect)rect encoding:(BEncoding)encoding{
    if (string == nil) {
        return nil;
    }

    BOOL startWithNewLine           = [string startWithNewLine];
    NSUInteger loc                  = 0;
    NSString* cache                 = [string trim];
    TypeSetter* setter              = [TypeSetter shareInstance];
    NSMutableArray* array           = [[NSMutableArray alloc] init];
    NSStringEncoding encoding_type  = [self parseBEncoding:encoding];
    Page* page                      = [[Page alloc] initWithString:cache encoding:encoding_type];
    page.startWithNewLine           = startWithNewLine;

    [setter fixPage:page bound:rect encoding:encoding];
    [array  addObject:page];

    while (cache.length > page.string.length) {
        loc                     = loc + page.range.length;
        cache                   = [cache substringFromIndex:page.string.length];
        startWithNewLine        = [[string substringToIndex:[string rangeOfString:cache].location] endWithNewLine];
        page                    = [[Page alloc] initWithString:cache encoding:encoding_type];
        page.range              = NSMakeRange(loc, page.range.length);
        page.startWithNewLine   = startWithNewLine;

        [setter fixPage:page bound:rect encoding:encoding];
        [array  addObject:page];
    }

    return array;
}

+(NSString*) getTxtOfChapater:(NSMutableArray *)chapaters atIndex:(NSUInteger)index inBook:(Book *)book{
    Catalog* _curr      = [chapaters objectAtIndex:index];
    Catalog* _next      = index >= chapaters.count-1 ? nil:[chapaters objectAtIndex:index+1];
    NSUInteger length   = (NSUInteger)(_next == nil? book.size - _curr.position : _next.position - _curr.position);
    Page* page          = [self getPageInBook:book position:_curr.position length:length refLen:NSUIntegerMax dir:FORWORD];
    return page.string;
}

/** 反转字符串 */
+(NSString*) reverseNSString:(NSString *)src{
    if (src == nil || src.length <= 0) {return nil;}
    NSUInteger len = [src length];
    wchar_t* buf = (wchar_t*)[src cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    wchar_t tmp;
    for(int i=0; len-i-1>i; ++i){
        tmp = buf[i];
        buf[i] = buf[len-i-1];
        buf[len-i-1] = tmp;
    }
    src = [[NSString alloc] initWithBytes:buf length:sizeof(wchar_t)*len encoding:NSUTF32LittleEndianStringEncoding];
    return src;
}

/** 统计字符串｛target｝在｛src｝中出现的次数 **/
+(NSInteger) countNSString:(NSString *)target inSrc:(NSString *)src{
    if (src == nil || src.length <= 0) {return -1;}
    if (target == nil || target.length <= 0) {return -1;}
    NSRange range = [src rangeOfString:target];
    NSInteger count = 0;
    while (range.location!=NSNotFound) {
        count++;
        src = [src substringFromIndex:range.location+range.length];
        range = [src rangeOfString:target];
    }
    return count;
}

+(BFileType) getTypeOfFile:(NSString *)fileName{
    if(fileName==nil||fileName.length<=0){return UNKONW;}
    fileName = [fileName lowercaseString];
    if([fileName hasSuffix:@"txt"]){return TXT;}else
        if([fileName hasSuffix:@"zip"]){return ZIP;}else//Unsupport @v.1.0
            if([fileName hasSuffix:@"epu"]){return EPU;}else//Unsupport @v.1.0
                if([fileName hasSuffix:@"pdf"]){return PDF;}else//Unsupport @v.1.0
                    if([fileName hasSuffix:@"jar"]){return JAR;}else//Unsupport @v.1.0
                        {return UNKONW;}
}
+(NSString*) getEncodingString:(BEncoding)encoding{return encoding<0?@"UNKONW":ENCODING_STR[encoding];}
+(NSString*) getFileTypeString:(BFileType)fileType{return fileType==TXT?@"TXT":@"UNSUPPORT";}
@end

#pragma implementatin for call BookLoader
@interface BookLoader(){
    CGRect          _bounds;
    Book*           _book;
    Catalog*        _chapter;
    BookMark*       _bookmark;
    NSInteger       _chapterIndex;
    NSUInteger      _pageIndex;
    NSMutableArray* _cacheQueue[3];
    NSUserDefaults* _userProfile;
}
@end

@implementation BookLoader
-(id) initWithBook:(Book *)book bookMark:(BookMark *)bookMark{
    self = [super init];
    if (self) {
        _book = book;
        _bookmark = bookMark;
        _userProfile = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(void) buildCache:(CGRect)bounds{
    NSObject* catalog = [_userProfile objectForKey:[NSString stringWithFormat:@"_catalog_for_%@", _book.name]];
    if (catalog != nil && _book.catalog == nil) {
        DLog(@"Reader catalog from user profile!");
        NSMutableArray* dataArray = (NSMutableArray*)catalog;
        _book.catalog = [[NSMutableArray alloc] init];
        for (NSData* data in dataArray){
            Catalog* log = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [_book.catalog addObject:log];
        }
    }


    if (_book.catalog == nil || _book.catalog.count == 0) {
        _book.catalog = [BookUtils getCatalog:_book];
        if (_book.catalog!=nil) {
            NSMutableArray* dataArray = [[NSMutableArray alloc] init];
            for (Catalog* log in _book.catalog){
                NSData* data = [NSKeyedArchiver archivedDataWithRootObject:log];
                [dataArray addObject:data];
            }
            [_userProfile setObject:dataArray forKey:[NSString stringWithFormat:@"_catalog_for_%@", _book.name]];
        }
    }

    if (_book.catalog == nil || _book.catalog.count == 0) {
        [NSException raise:EXCEPTION_BUILD_CACHE_ERROR format:@""];
    }

    NSUInteger index = 0;
    if (_bookmark != nil && _bookmark.position > 0) {
        for (Catalog *catalog in _book.catalog) {
            if (catalog.position < _bookmark.position) {
                ++index;
            } else if(catalog.position > _bookmark.position){
                --index;
                break;
            } else {
                break;
            }
        }
    } else {
        _bookmark = [[BookMark alloc] init];
        _bookmark.position = 0;
    }

    NSString* chapaterTxt = [BookUtils getTxtOfChapater:_book.catalog atIndex:index inBook:_book];
    _cacheQueue[1] = [BookUtils pagingOfString:chapaterTxt inRect:bounds encoding:_book.encoding];

    if (index != 0) {
        chapaterTxt = [BookUtils getTxtOfChapater:_book.catalog atIndex:index-1 inBook:_book];
        _cacheQueue[0] = [BookUtils pagingOfString:chapaterTxt inRect:bounds encoding:_book.encoding];
    }

    if (index < _book.catalog.count - 1) {
        chapaterTxt = [BookUtils getTxtOfChapater:_book.catalog atIndex:index+1 inBook:_book];
        _cacheQueue[2] = [BookUtils pagingOfString:chapaterTxt inRect:bounds encoding:_book.encoding];
    }

    ((Page*)[_cacheQueue[0] objectAtIndex:0]).startWithNewLine = YES;
    ((Page*)[_cacheQueue[1] objectAtIndex:0]).startWithNewLine = YES;
    ((Page*)[_cacheQueue[2] objectAtIndex:0]).startWithNewLine = YES;

    _chapter        = [_book.catalog objectAtIndex:index];
    _chapterIndex   = index;
    _bounds         = bounds;

    DLog(@"At %@", [_bookmark description]);

    int i = 0;
    NSUInteger loc = 0;
    for(Page* page in _cacheQueue[1]){
        loc = page.range.location + _chapter.position;
        if (loc == _bookmark.position) {
            break;
        } else if(loc > _bookmark.position){
            --i;
            break;
        }
        ++i;
    }

    _pageIndex      = i;
}

-(Page*) nextPage{
    if (_pageIndex < _cacheQueue[1].count - 1) {    
        return [_cacheQueue[1] objectAtIndex:++_pageIndex];
    }

    if (_chapterIndex >= _book.catalog.count-1 || _cacheQueue[2] == nil) {
        //[NSException raise:EXCEPTION_IS_LAST_PAGE format:@""];
        return [self currPage];
    }

    _pageIndex      = 0;
    _chapter        = [_book.catalog objectAtIndex:++_chapterIndex];
    _cacheQueue[0]  = _cacheQueue[1];
    _cacheQueue[1]  = _cacheQueue[2];

    if (_chapterIndex+1 <= _book.catalog.count-1) {
        NSString* txt   = [BookUtils getTxtOfChapater:_book.catalog atIndex:_chapterIndex+1 inBook:_book];
        _cacheQueue[2]  = [BookUtils pagingOfString:txt inRect:_bounds encoding:_book.encoding];
        ((Page*)[_cacheQueue[2] objectAtIndex:0]).startWithNewLine = YES;
    } else {
        _cacheQueue[2]  = nil;
    }

    return [_cacheQueue[1] objectAtIndex:_pageIndex];
}

-(Page*) prevPage{
    if (_pageIndex > 0) {
        return [_cacheQueue[1] objectAtIndex:--_pageIndex];
    }

    if (_chapterIndex <= 0 || _cacheQueue[0] == nil) {
        //[NSException raise:EXCEPTION_IS_FIRST_PAGE format:@""];
        return [self currPage];
    }

    _pageIndex      = _cacheQueue[0].count-1;
    _chapter        = [_book.catalog objectAtIndex:--_chapterIndex];
    _cacheQueue[2]  = _cacheQueue[1];
    _cacheQueue[1]  = _cacheQueue[0];

    if (_chapterIndex-1 >= 0) {
        NSString* txt   = [BookUtils getTxtOfChapater:_book.catalog atIndex:_chapterIndex-1 inBook:_book];
        _cacheQueue[0]  = [BookUtils pagingOfString:txt inRect:_bounds encoding:_book.encoding];
        ((Page*)[_cacheQueue[0] objectAtIndex:0]).startWithNewLine = YES;
    } else {
        _cacheQueue[0]  = nil;
    }

    return [_cacheQueue[1] objectAtIndex:_pageIndex];
}

-(Page*) currPage{
    return [_cacheQueue[1] objectAtIndex:_pageIndex];
}

-(Page*) jumpTo:(NSUInteger)position{
    _bookmark.position = position;
    [self buildCache:_bounds];
    return [_cacheQueue[1] objectAtIndex:_pageIndex];
}

-(BookMark*) getBookMark{
    _bookmark.position  = [self currPage].range.location + _chapter.position;
    _bookmark.name      = [[NSDate date] description];
    _bookmark.time      = [[NSDate date] timeIntervalSince1970] * 1000.0f;
    _book.mark          = _bookmark;
    return _bookmark;
}

-(Catalog*) catalogInfo{
    return _chapter;
}
@end