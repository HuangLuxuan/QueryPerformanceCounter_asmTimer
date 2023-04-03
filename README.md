# QueryPerformanceCounter_asmTimer
## 什么？用汇编写Win32程序？
你没听错！用**C语言**写都会**又臭又长**的Win32程序！就是它，现在要用**汇编语言**来写（当然只是个小小的demo）  
## 什么？不用msvcrt？？
没错！纯汇编嘛，用了VC运行库就输啦！！**TOTALLY C/C++ FREE!!!**（当然WinAPI是C写的这我没办法）  
## NoCRTMain!!!
什么？你程序的主函数是int __cdecl main(int argc, const char \*\*argv, const char \*\*envp)？**弱爆了！！**  
什么？你程序的主函数是int __stdcall WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)？**弱爆了**  
**NOW INTRODUCING: int __stdcall NoCRTMain(void)**  
让你体验完全由自己支配exe的快感！！**你的函数，就是exe的入口**  

啊，当然，Win32程序的灵魂肯定不能缺少  
**没有int __stdcall WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)的程序好意思叫自己是Win32程序？**  
所以呢，NoCRTMain就要给WinMain准备一下，流程嘛，得走  
然后呢，计时就是用WinAPI中的[QueryPerformanceCounter](https://learn.microsoft.com/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter?redirectedfrom=MSDN)  
## 整个程序的导入表只有Kernel32.dll和User32.dll中的函数
KERNEL32:  
[GetLastError](https://learn.microsoft.com/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror)  
[FormatMessageW](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-formatmessagew)  
[lstrlenW](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-lstrlenw)  
[LocalAlloc](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-localalloc)  
[LocalFree](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-localfree)  
[GetCommandLineA](https://learn.microsoft.com/windows/win32/api/processenv/nf-processenv-getcommandlinea)  
[GetModuleHandleA](https://learn.microsoft.com/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlea)  
[ExitProcess](https://learn.microsoft.com/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess)  
[QueryPerformanceFrequency](https://learn.microsoft.com/windows/win32/api/profileapi/nf-profileapi-queryperformancefrequency)  
[QueryPerformanceCounter](https://learn.microsoft.com/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter)  
USER32:  
[MessageBoxW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-messageboxw)  
[wsprintfW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-wsprintfw)  
[RegisterClassExW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-registerclassexw)  
[CreateWindowExW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-createwindowexw)  
[ShowWindow](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-showwindow)  
[UpdateWindow](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-updatewindow)  
[GetMessageW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-getmessagew)  
[TranslateMessage](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-translatemessage)  
[DispatchMessageW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-dispatchmessagew)  
[PostQuitMessage](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-postquitmessage)  
[KillTimer](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-killtimer)  
[SetTimer](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-settimer)  
[SendMessageW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-sendmessagew)  
[DefWindowProcW](https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-defwindowprocw)  

**如你所见，没有msvcrt的函数！！**
## 那怎么编译链接呢
**NASM**是更加先进的汇编器，官网[在这](https://www.nasm.us/)，本程序编写时用的是2.16.01版本的nasm  
**NASMx**是它的一个很优秀的插件，在[这里](https://forum.nasm.us/?board=11)能找到很详细的信息，本程序编写时用的是1.4版本的nasmx  
如果你不知道nasm和nasmx怎么用，可以去逛逛nasm的[论坛](https://forum.nasm.us/)（或者去[百度](https://www.baidu.com/s?ie=UTF-8&wd=%E6%88%91%E6%80%BB%E6%98%AF%E8%AE%B0%E4%B8%8D%E4%BD%8F%E7%99%BE%E5%BA%A6%E6%90%9C%E7%B4%A2%E7%9A%84%E7%BD%91%E5%9D%80%E6%80%8E%E4%B9%88%E5%8A%9E)[谷歌](https://www.google.com.hk/search?q=%E6%88%91%E6%80%BB%E6%98%AF%E8%AE%B0%E4%B8%8D%E4%BD%8F%E8%B0%B7%E6%AD%8C%E6%90%9C%E7%B4%A2%E7%9A%84%E7%BD%91%E5%9D%80%E6%80%8E%E4%B9%88%E5%8A%9E)）  
然后，用类似于这样的命令来编译链接
```
nasm -f win32 PerformanceCounter.asm
golink /debug coff /mix /entry NoCRTMain PerformanceCounter.obj kernel32.dll user32.dll
```
## 查询作者精神状态
[点击链接即可查询](https://space.bilibili.com/24022863)
