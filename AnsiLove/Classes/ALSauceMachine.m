//
//  ALSauceMachine.m
//  AnsiLove.framework
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//
//  Based on libsauce. Copyright (c) 2010, Brian Cassidy. 
//

#import "ALSauceMachine.h"

@implementation ALSauceMachine

# pragma -
# pragma mark bridge methods (Cocoa)

- (id)init
{
    if (self == [super init]) {}
    return self;
}

+ (void)readSauceRecordFromFile:(NSString *)inputFile 
{
    if (inputFile == nil || inputFile == @"") {
        // Y U NO have content? U get outta my method!
        return;
    }
    
    // Resolve any tilde in path. Ladies and gentlemen, this is a feature.
    inputFile = [inputFile stringByExpandingTildeInPath];
    
    // Convert our NSString instance to a C string.
    const char *inputChar = [inputFile UTF8String];
    
    // Now that we have a C string, pass it typecasted.
    sauce *record = sauceReadFileName((char *)inputChar);
    
    // No Sauce record inside the file? Stop here.
    if (strcmp(record->id, SAUCE_ID) != 0) {
        NSLog(@"File does not have a SAUCE record");
        return;
    }
    
    // Let us admire the sauce record in NSLog.
    // THIS IS JUST FOR TESTING - A BETTER IMPLEMENTATION IS ON THE WAY!
    NSLog(@"%9s: [%s]\n", "id", record->id);
    NSLog(@"%9s: [%s]\n", "version", record->version);
    NSLog(@"%9s: [%s]\n", "title", record->title);
    NSLog(@"%9s: [%s]\n", "autor", record->author);
    NSLog(@"%9s: [%s]\n", "group", record->group);
    NSLog(@"%9s: [%s]\n", "date", record->date);
    NSLog(@"%9s: [%d]\n", "filesize", record->filesize);
    NSLog(@"%9s: [%d]\n", "datatype", record->datatype);
    NSLog(@"%9s: [%d]\n", "filetype", record->filetype);
    NSLog(@"%9s: [%d]\n", "tinfo1", record->tinfo1);
    NSLog(@"%9s: [%d]\n", "tinfo2", record->tinfo2);
    NSLog(@"%9s: [%d]\n", "tinfo3", record->tinfo3);
    NSLog(@"%9s: [%d]\n", "tinfo4", record->tinfo4);
    NSLog(@"%9s: [%d]\n", "comments", record->comments);
    if (record->comments > 0) {
        NSInteger i;
        for (i = 0; i < record->comments; i++) {
            NSLog(@"%9s: [%s]\n", "", record->comment_lines[ i ]);
        }
    }
    NSLog(@"%9s: [%d]\n", "flags", record->flags);
    NSLog(@"%9s: [%s]\n", "filler", record->filler);
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
    if (fseek(file, 0 - RECORD_SIZE, SEEK_END) != 0) {
        free(record);
        return;
    }
    
    NSInteger read_status = fread(record->id, sizeof(record->id) - 1, 1, file);
    record->id[sizeof(record->id) - 1] = '\0';
    
    if (read_status != 1 || strcmp(record->id, SAUCE_ID) != 0) {
        free(record);
        return;
    }
    if (fread(record->version, sizeof(record->version) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE version");
    }
    record->version[sizeof(record->version) - 1] = '\0';
    if (fread(record->title, sizeof(record->title) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE title");
    }
    record->title[sizeof(record->title) - 1] = '\0';
    if (fread(record->author, sizeof(record->author) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE author");
    }
    record->author[sizeof(record->author) - 1] = '\0';
    if (fread(record->group, sizeof(record->group) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE group");
    }
    record->group[sizeof(record->group) - 1] = '\0';
    if (fread(record->date, sizeof(record->date) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE date");
    }
    record->date[sizeof(record->date) - 1] = '\0';
    if (fread(&(record->filesize), sizeof(record->filesize), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE filesize");
    }
    if (fread(&(record->datatype), sizeof(record->datatype), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE datatype");
    }
    if (fread(&(record->filetype), sizeof(record->filetype), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE filetype");
    }
    if (fread(&(record->tinfo1), sizeof(record->tinfo1), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE tinfo1");
    }
    if (fread(&(record->tinfo2), sizeof(record->tinfo2), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE tinfo2");
    }
    if (fread(&(record->tinfo3), sizeof(record->tinfo3), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE tinfo3");
    }
    if (fread(&(record->tinfo4), sizeof(record->tinfo4), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE tinfo4");
    }
    if (fread(&(record->comments), sizeof(record->comments), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE comments");
    }
    if (fread(&(record->flags), sizeof(record->flags), 1, file) != 1) {
        NSLog(@"Unable to read SAUCE flags");
    }
    if (fread(record->filler, sizeof(record->filler) - 1, 1, file) != 1) {
        NSLog(@"Unable to read SAUCE filler");
    }
    record->filler[sizeof(record->filler) - 1] = '\0';
    
    if (ferror(file) != 0) {
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
    
    if (fseek(file, 0 - (RECORD_SIZE + 5 + COMMENT_SIZE *comments), SEEK_END) == 0) {
        char id[6];
        if (fread(id, sizeof(id) - 1, 1, file) != 1) {
            NSLog(@"COMNT record truncated (ID failed)");
        }
        id[sizeof(id) - 1] = '\0';
        
        if (strcmp(id, COMMENT_ID) != 0) {
            free(comment_lines);
            return;
        }
        for (i = 0; i < comments; i++) {
            char buf[COMMENT_SIZE + 1] = "";
            
            if (fread(buf, COMMENT_SIZE, 1, file) != 1) {
                NSLog(@"COMNT record truncated (comment line failed)");
            }
            buf[COMMENT_SIZE] = '\0';
            
            if (ferror(file) == 0) {
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
    if (sauceRemoveFile(file) == 0) {
        NSInteger rc = writeRecord(file, record);
        return rc;
    }
    else {
        return EXIT_FAILURE;
    }
}

NSInteger writeRecord(FILE *file, sauce *record) 
{
    if (fseek(file, 0, SEEK_END) != 0) {
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
    fwrite(record->id, sizeof(record->id) - 1, 1, file);
    fwrite(record->version, sizeof(record->version) - 1, 1, file);
    fwrite(record->title, sizeof(record->title) - 1, 1, file);
    fwrite(record->author, sizeof(record->author) - 1, 1, file);
    fwrite(record->group, sizeof(record->group) - 1, 1, file);
    fwrite(record->date, sizeof(record->date) - 1, 1, file);
    fwrite(&(record->filesize), sizeof(record->filesize), 1, file);
    fwrite(&(record->datatype), sizeof(record->datatype), 1, file);
    fwrite(&(record->filetype), sizeof(record->filetype), 1, file);
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
    
    if (record == NULL || strcmp(record->id, SAUCE_ID) != 0) {
        return EXIT_SUCCESS;
    }
    if (ftruncate(fileno(file), record->filesize) != 0) {
        NSLog(@"Truncate failed");
    }
    return EXIT_SUCCESS;
}

@end
