#include "pch.h"
#include <stdio.h> 
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <iostream>
#include <tchar.h> 

//#define VERBOSE

static char* humanSize(uint64_t bytes)
{
    const char* suffix[] = { "B", "KB", "MB", "GB", "TB" };
    char length = sizeof(suffix) / sizeof(suffix[0]);

    int i = 0;
    double dblBytes = (double)bytes;

    if (bytes > 1024) {
        for (i = 0; (bytes / 1024) > 0 && i < length - 1; i++, bytes /= 1024)
            dblBytes = bytes / 1024.0;
    }

    static char output[200];
    sprintf_s(output, "%.02lf %s", dblBytes, suffix[i]);
    return output;
}

extern "C" __declspec(dllexport) const char* cdecl BytesToString(uint64_t size)
{
    #ifdef VERBOSE
    std::cout << humanSize(size) << std::endl;
    #endif
    return humanSize(size);
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        #ifdef VERBOSE
        AllocConsole();
        freopen("CONIN$", "r", stdin);
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
        #endif
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

