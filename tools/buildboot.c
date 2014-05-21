/*************************************************************************
	> File Name: buildboot.c
	> Author: lcy
	> Mail: 710640803@qq.com 
	> Created Time: 2014年05月21日 星期三 12时41分36秒
 ************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<memory.h>
int main(){
    FILE * f1, *f2,*f3;
    f1 = fopen("/home/lichunyao/github/MYOS/boot/boot.bin","r+");
    f2 = fopen("/home/lichunyao/github/MYOS/boot/setup.bin","r+");
    f3 = fopen("/home/lichunyao/github/MYOS/sysimg","w+");
    char buf[512];
    fread(buf,1,512,f1);
    fwrite(buf,1,512,f3);
    memset(buf,0,512);
    fread(buf,1,512,f2);
    fwrite(buf,1,512,f3);
    fclose(f1);
    fclose(f2);
    fclose(f3);
    return 0;

}
