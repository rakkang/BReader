//
//  BookUtils.h
//  BReader
//
//  Created by ruikye on 14-3-29.
//
//

#import <Foundation/Foundation.h>

#pragma all class
@class Catalog, BEXCEPTION, BookUtils, Page, BookMark, Book;

#pragma class define begin
@interface Catalog : NSObject<NSCoding>
@property(nonatomic, copy) NSString* name;
@property(nonatomic, assign) NSUInteger position;
@end

typedef enum{
    ERROR        = -1,
    ANSI         =  0,
    UTF_8        =  1,
    UNICODE      =  2,
    UNICODE_BIG  =  3
}BEncoding;

typedef enum{
    FORWORD      =  0,
    BACKWORD     =  1
}BDirection;

typedef enum{
    UNKONW       = -1,
    TXT          =  0,
    ZIP          = -1, //Unsupport @v.1.0
    EPU          = -1, //Unsupport @v.1.0
    PDF          = -1, //Unsupport @v.1.0
    JAR          = -1  //Unsupport @v.1.0
}BFileType;

@interface BEXCEPTION : NSObject
+(NSString*) Loader_IsFirstPageException;
+(NSString*) Loader_IsLastPagException;
+(NSString*) Loader_BuildCacheException;
+(NSString*) unsupportTypeException;
+(NSString*) unsupportEncodingException;
@end

@interface BookUtils : NSObject
+(long long) getSizeWithBytes:(NSString*) fileName;
+(NSMutableArray*) getCatalog:(Book*) book;
+(NSMutableArray*) getCatalog:(NSString*)fileName encoding:(BEncoding) encoding;
+(Page*) getPageInBook:(Book*)book position:(NSUInteger)position length:(NSUInteger)bufLength refLen:(NSUInteger) refLength dir:(BDirection)dir;
+(Page*) getPageInFile:(NSString*) fileName position:(NSUInteger) position length:(NSUInteger) bufLength refLen:(NSUInteger) refLength dir:(BDirection) dir encoding:(BEncoding) encoding;
+(BFileType) getTypeOfFile:(NSString*) fileName;
+(BEncoding) getTxtEncoding:(NSString *)fileName;
+(BOOL) isBookHeader:(Catalog*) catalog;
+(NSString*) getEncodingString:(BEncoding) encoding;
+(NSString*) getFileTypeString:(BFileType) fileType;
+(NSString*) getTxtOfChapater:(NSMutableArray*) chapaters atIndex:(NSUInteger)index inBook:(Book*)book;
+(NSMutableArray*) pagingOfBook:(Book*) book byRange:(NSRange)range inRect:(CGRect)rect;
+(NSMutableArray*) pagingOfString:(NSString*) string inRect:(CGRect)rect encoding:(BEncoding)encoding;
+(NSStringEncoding) parseBEncoding:(BEncoding) encoding;
@end

@interface NSString(StringUtil)
-(BOOL) endWithNewLine;
-(BOOL) startWithNewLine;
-(instancetype) reverse;
-(instancetype) trim;
-(NSInteger) countSubString:(NSString*) sub;
@end

@interface Page : NSObject
@property NSString* string;
@property NSRange range;
@property BOOL startWithNewLine;
-(id) initWithString:(NSString*) string encoding:(NSStringEncoding)encoding;
-(NSUInteger) nextPosition;
@end

@interface BookMark : NSObject<NSCoding>
@property NSUInteger time;
@property NSUInteger position;
@property NSString* name;
@end

@interface Book : NSObject
@property NSString* path;
@property NSString* name;
@property NSString* fullPath;
@property NSUInteger lastOpenTime;
@property BookMark* mark;
@property long long size;
@property BFileType type;
@property BEncoding encoding;
@property NSMutableArray* catalog;
+(Book*) forName:(NSString*)name;
+(Book*) forName:(NSString*)name forType:(BFileType) type;
+(Book*) forName:(NSString*)name inPath:(NSString*) path;
+(Book*) forName:(NSString*)name inPath:(NSString*) path forType:(BFileType) type;
-(NSString*) simpleName;
-(void) saveBookMark;
-(void) readBookMark;
@end

@interface BookLoader : NSObject
-(id) initWithBook:(Book*) book bookMark:(BookMark*) bookMark;
-(void) buildCache:(CGRect)bounds;
-(Page*) nextPage;
-(Page*) prevPage;
-(Page*) currPage;
-(Page*) jumpTo:(NSUInteger)position;
-(BookMark*) getBookMark;
-(Catalog*) catalogInfo;
@end
