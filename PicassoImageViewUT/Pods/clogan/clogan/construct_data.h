//
// Created by baitian0521 on 17/8/1.
//

#ifndef CLOGAN_BUILD_DATA_H
#define CLOGAN_BUILD_DATA_H




typedef struct{
    char* data;
    int data_len;
} Construct_Data_cLogan;

Construct_Data_cLogan* construct_json_data_clogan(char *log, int flag, long long sync_time, long long local_time, char *thread_name,
                                           long long thread_id, int ismain , char * extra_tag);

void construct_data_delete_clogan(Construct_Data_cLogan *data);

#endif //CLOGAN_BUILD_DATA_H
