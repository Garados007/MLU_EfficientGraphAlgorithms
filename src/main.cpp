
#include <iostream>

#if defined(WIN32) && !defined(NDEBUG)

  #include <Windows.h>
  #include <sstream>

class dbg_stream_for_cout : public std::stringbuf
{
  public:
    ~dbg_stream_for_cout()
    {
        sync();
    }

    int sync()
    {
        ::OutputDebugStringA(str().c_str());
        str(std::string()); // Clear the string buffer
        return 0;
    }
};

dbg_stream_for_cout g_DebugStreamFor_cout;
#endif

int main(int /*argc*/, char ** /*argv*/)
{
#if defined(WIN32) && !defined(NDEBUG)
    if(IsDebuggerPresent())
    {
        // This statement redirects all output to console to the debugging windows of Visual Studio.
        // This is only necessary on Windows and for debugging.
        std::cout.rdbuf(&g_DebugStreamFor_cout);
        std::cerr.rdbuf(&g_DebugStreamFor_cout);
    }
#endif

    std::cout << "Hello world!" << std::endl;
    return 0;
}
