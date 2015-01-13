//
//  ALSauceMachine.m
//  AnsiLove.framework
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//
//  Based on libsauce. Copyright (c) 2010, Brian Cassidy. 
//

#import "ALSauceMachine.h"

@implementation ALSauceMachine

@synthesize ID, version, title, author, group, date, dataType, fileType, flags, 
            tinfo1, tinfo2, tinfo3, tinfo4, comments, fileHasRecord, fileHasComments, 
            fileHasFlags;

# pragma -
# pragma mark bridge methods (Cocoa)

- (id)init
{
    if (self == [super init]) 
    {
        // Init the comments string property (absolutely necessary).
        self.comments = @"";
    }
    return self;
}

- (void)readRecordFromFile:(NSString *)inputFile 
{
    if (inputFile == nil || [inputFile isEqual:@""]) {
        // Y U NO have content? U get outta my method!
        return;
    }
    
    // Resolve any tilde in path. Ladies and gentlemen, this is a feature.
    inputFile = [inputFile stringByExpandingTildeInPath];
    
    // Convert our NSString instance to a C string.
    const char *inputChar = [inputFile UTF8String];
    
    // Now that we have a C string, pass it typecasted.
    sauce *record = sauceReadFileName((char *)inputChar);
    
    // No SAUCE record inside the file? Stop here.
    if (strcmp(record->ID, SAUCE_ID) != IDENTICAL) {
        self.fileHasRecord = NO;
        return;
    }
    else {
        self.fileHasRecord = YES;
    }
    
    // Assign string values of the SAUCE record struct to our ObjC properties.
    self.ID = [NSString stringWithFormat:@"%s", record->ID];  
    self.version = [NSString stringWithFormat:@"%s", record->version];
    self.title = [NSString stringWithFormat:@"%s", record->title];
    self.author = [NSString stringWithFormat:@"%s", record->author];
    self.group = [NSString stringWithFormat:@"%s", record->group];
    self.date = [NSString stringWithFormat:@"%s", record->date];
    
    // Primitive data types don't need conversion, we just refer a = b.
    self.dataType = record->dataType;
    self.fileType = record->fileType;
    self.tinfo1 = record->tinfo1;
    self.tinfo2 = record->tinfo2;
    self.tinfo3 = record->tinfo3;
    self.tinfo4 = record->tinfo4;
    self.flags = record->flags;
    
    // Now append the record's comments (if existing) to an NSString instance.
    if (record->comments > 0) {
        self.fileHasComments = YES;
        NSInteger i;
        for (i = 0; i < record->comments; i++) {
            self.comments = [self.comments stringByAppendingString:
                             [NSString stringWithFormat:@"%s\n", record->comment_lines[i]]];
        }
        // After merging the comment lines, we should also remove the last
        // newline occurence. JUST BECAUSE WE CAN.
        NSMutableString *tempCommentString = [NSMutableString stringWithString:self.comments];
        NSRange newLineRange = [tempCommentString rangeOfString:@"\n" options:NSBackwardsSearch];
        [tempCommentString replaceCharactersInRange:newLineRange withString:@""];
        self.comments = [NSString stringWithFormat:@"%@", tempCommentString];
    }
    else {
        self.fileHasComments = NO;
    }    
    
    // Finally we should check if the file has flags.
    if (self.flags > 0) {
        self.fileHasFlags = YES;
    }
    else {
        self.fileHasFlags = NO;
    }
}

# pragma -
# pragma mark class internal (C)

// Reads SAUCE via a filename.
// @param filename (the filename to read)
sauce *sauceReadFileName(char *fileName) 
{
    FILE *file = fopen(fileName, "r");
    if (file == NULL) {
        return NULL;
    }
    
    sauce *record = sauceReadFile(file);
    fclose(file);
    return record;
}

// Read SAUCE via a FILE pointer.
// @param file (the FILE pointer to read)
sauce *sauceReadFile(FILE *file) 
{
    sauce *record;
    record = malloc(sizeof *record);
    
    if (record != NULL) {
        readRecord(file, record);
    }
    return record;
}

void readRecord(FILE *file, sauce *record) 
{
    if (fseek(file, 0 - RECORD_SIZE, SEEK_END) != EXIT_SUCCESS) {
        free(record);
        return;
    }
    
    NSInteger read_status = fread(record->ID, sizeof(record->ID) - 1, 1, file);
    record->ID[sizeof(record->ID) - 1] = '\0';
    
    if (read_status != 1 || strcmp(record->ID, SAUCE_ID) != IDENTICAL) {
        free(record);
        return;
    }
    fread(record->version, sizeof(record->version) - 1, 1, file);
    record->version[sizeof(record->version) - 1] = '\0';
    fread(record->title, sizeof(record->title) - 1, 1, file);    
    record->title[sizeof(record->title) - 1] = '\0';
    fread(record->author, sizeof(record->author) - 1, 1, file);
    record->author[sizeof(record->author) - 1] = '\0';
    fread(record->group, sizeof(record->group) - 1, 1, file);    
    record->group[sizeof(record->group) - 1] = '\0';
    fread(record->date, sizeof(record->date) - 1, 1, file);
    record->date[sizeof(record->date) - 1] = '\0';
    fread(&(record->fileSize), sizeof(record->fileSize), 1, file);    
    fread(&(record->dataType), sizeof(record->dataType), 1, file);    
    fread(&(record->fileType), sizeof(record->fileType), 1, file);
    fread(&(record->tinfo1), sizeof(record->tinfo1), 1, file);
    fread(&(record->tinfo2), sizeof(record->tinfo2), 1, file);
    fread(&(record->tinfo3), sizeof(record->tinfo3), 1, file);
    fread(&(record->tinfo4), sizeof(record->tinfo4), 1, file);
    fread(&(record->comments), sizeof(record->comments), 1, file);
    fread(&(record->flags), sizeof(record->flags), 1, file);
    fread(record->filler, sizeof(record->filler) - 1, 1, file);
    record->filler[sizeof(record->filler) - 1] = '\0';
    
    if (ferror(file) != EXIT_SUCCESS) {
        free(record);
        return;
    }
    
    if (record->comments > 0) {
        record->comment_lines = malloc(record->comments *sizeof(*record->comment_lines));
        
        if (record->comment_lines != NULL) {
            readComments(file, record->comment_lines, record->comments);
        }
        else {
            free(record);
            return;
        }
    }
}

void readComments(FILE *file, char **comment_lines, NSInteger comments) 
{
    NSInteger i;
    
    if (fseek(file, 0 - (RECORD_SIZE + 5 + COMMENT_SIZE *comments), SEEK_END) == EXIT_SUCCESS) {
        char ID[6];
        fread(ID, sizeof(ID) - 1, 1, file);
        ID[sizeof(ID) - 1] = '\0';
        
        if (strcmp(ID, COMMENT_ID) != IDENTICAL) {
            free(comment_lines);
            return;
        }
        
        for (i = 0; i < comments; i++) {
            char buf[COMMENT_SIZE + 1] = "";
            
            fread(buf, COMMENT_SIZE, 1, file);
            buf[COMMENT_SIZE] = '\0';
            
            if (ferror(file) == EXIT_SUCCESS) {
                comment_lines[i] = strdup(buf);
                if (comment_lines[i] == NULL) {
                    free(comment_lines);
                    return;
                }
            }
            else {
                free(comment_lines);
                return;
            }
        }
        return;
    }    
    free(comment_lines);
    return;
}

// Write SAUCE via a filename.
// @param filename (the filename in which to write the SAUCE record)
NSInteger sauceWriteFileName(char *fileName, sauce *record) 
{
    FILE *file = fopen(fileName, "r+");
    
    if (file == NULL) {
        return EXIT_FAILURE;
    }
    
    NSInteger rc = sauceWriteFile(file, record);
    fclose(file);
    return rc;
}


// Write SAUCE via a FILE pointer.
// @param file The FILE pointer in which to write the SAUCE record
NSInteger sauceWriteFile(FILE *file, sauce *record) 
{
    if (sauceRemoveFile(file) == EXIT_SUCCESS) {
        NSInteger rc = writeRecord(file, record);
        return rc;
    }
    else {
        return EXIT_FAILURE;
    }
}

NSInteger writeRecord(FILE *file, sauce *record) 
{
    if (fseek(file, 0, SEEK_END) != EXIT_SUCCESS) {
        return EXIT_FAILURE;
    }
    
    fwrite("\032", 1, 1, file);
    
    if (record->comments != 0) {
        fwrite(COMMENT_ID, 5, 1, file);
        NSInteger i;
        for (i = 0; i < record->comments; i++) {
            fwrite(record->comment_lines[i], COMMENT_SIZE, 1, file);
        }
    }
    fwrite(record->ID, sizeof(record->ID) - 1, 1, file);
    fwrite(record->version, sizeof(record->version) - 1, 1, file);
    fwrite(record->title, sizeof(record->title) - 1, 1, file);
    fwrite(record->author, sizeof(record->author) - 1, 1, file);
    fwrite(record->group, sizeof(record->group) - 1, 1, file);
    fwrite(record->date, sizeof(record->date) - 1, 1, file);
    fwrite(&(record->fileSize), sizeof(record->fileSize), 1, file);
    fwrite(&(record->dataType), sizeof(record->dataType), 1, file);
    fwrite(&(record->fileType), sizeof(record->fileType), 1, file);
    fwrite(&(record->tinfo1), sizeof(record->tinfo1), 1, file);
    fwrite(&(record->tinfo2), sizeof(record->tinfo2), 1, file);
    fwrite(&(record->tinfo3), sizeof(record->tinfo3), 1, file);
    fwrite(&(record->tinfo4), sizeof(record->tinfo4), 1, file);
    fwrite(&(record->comments), sizeof(record->comments), 1, file);
    fwrite(&(record->flags), sizeof(record->flags), 1, file);
    fwrite(record->filler, sizeof(record->filler) - 1, 1, file);
    
    return EXIT_SUCCESS;
}

// Remove SAUCE via a filename.
// @param filename (the filename from which to remove the SAUCE record)
NSInteger sauceRemoveFileName(char *fileName) 
{
    FILE *file = fopen(fileName, "r+");
    
    if (file == NULL) {
        return EXIT_FAILURE;
    }
    
    NSInteger rc = sauceRemoveFile(file);
    
    fclose(file);
    return rc;
}

// Remove SAUCE via a FILE pointer.
// @param file The FILE pointer from which to remove the SAUCE record
NSInteger sauceRemoveFile(FILE *file) 
{
    sauce *record = sauceReadFile(file);
    
    if (record == NULL || strcmp(record->ID, SAUCE_ID) != IDENTICAL) {
        return EXIT_SUCCESS;
    }
    
    ftruncate(fileno(file), record->fileSize);    
    return EXIT_SUCCESS;
}

@end
