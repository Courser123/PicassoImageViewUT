//
// Created by baitian0521 on 17/7/31.
//


#ifndef CLOGAN_LOGAN_CORE_H
#define CLOGAN_LOGAN_CORE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <zlib.h>
#include <stdlib.h>
#include "logan_config.h"

/**
 * 开放接口
 * 前4个接口在Thread中调用(强调)
 * 1.clogan_init(char * pathdirs , int max_file ,unsigned char encryp_key[16]) 初始化文件目录、最大文件大小和秘钥
 * 2.clogan_open(char * pathname);打开一个文件
 * 3.clogan_write(....)写数据
 * 4.clogan_flush();缓存数据写入文件
 * 5.clogan_setdebug() 是否为debug环境 1为开启 0 为关闭
 * 注意事项：
 *   iOS8以后，模拟器的程序安装路径每次xcode运行安装时都会发生变化。所以在模拟器上进行调试会无法进行mmap回写
 */

/**
 @brief 初始化文件目录和最大文件大小
 @param cachedirs 指定缓存mmap的目录文件
 @param pathdirs  指定日志文件夹目录
 @param max_file  指定最大文件大小
 @param encrypt_key_factor 指定加密key的因子
 @param encrypt_key_len 指定加密key的长度
 */
int clogan_init(const char *cachedirs, const char *pathdirs, int max_file, const char *encrypt_key_factor,
                int encrypt_key_len);

/**
 @brief 打开一个文件的写入
 @param pathname  文件名称
 */
int clogan_open(const char *pathname); //打开一个文件的写入

/**
 @brief 写入数据 按照顺序和类型传值(强调、强调、强调)
 @param flag 日志类型 (int)
 @param ... 多参数，按照下面的顺序和类型传值
 log 日志内容 (char*)
 sync_time 同步过的日志发生时间，形如1502100065601 (long long)
 local_time 日志发生的本地时间，形如1502100065601 (long long)
 thread_name 线程名称 (char*)
 thread_id 线程id (long long) 为了兼容JAVA
 ismain 是否为主线程，0为是主线程，1位非主线程 (int)
 */
//int clogan_write(int flag, ...);

int clogan_write(int flag, char *log, long long sync_time, long long local_time, char *thread_name, long long thread_id,
               int ismain);

int
clogan_write_tag(int flag, char *log, long long sync_time, long long local_time, char *thread_name, long long thread_id,
                 int ismain, char *extra_tag);

/**
 @brief 强制写入文件。建议在崩溃或者退出程序的时候调用
 */
int clogan_flush();

/**
 @brief 是否为debug环境。debug环境将输出过程日志到控制台中
 @param debug 1为开启 0 为关闭
 */
void clogan_setDebug(int debug);

void clogan_setCatUpload(void (*item)(char *, int));

char *clogan_upload_key();

#ifdef __cplusplus
}
#endif
#endif //CLOGAN_LOGAN_CORE_H
