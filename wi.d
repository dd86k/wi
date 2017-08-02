import core.stdc.stdio : puts;
import core.stdc.stdlib : getenv;
import std.string : toLower, fromStringz, toStringz, split, indexOf;
import std.file : dirEntries, SpanMode, FileException;

version (Windows) enum DELIM = ';', DIRSEP = '\\', VARC = '%';
version (Posix)   enum DELIM = ':', DIRSEP = '/',  VARC = '$';

/**
 * Entry point.
 * Params: args = CLI Arguments.
 * Returns: Error code.
 */
int main(string[] args)
{
	if (args.length == 1)
	{
		puts("Search directories in PATH.");
		puts("Usage:");
		puts("  wi <string>");
		return 0;
	}

	if (args[1] == "--version")
	{
		puts("wi v1.0.0");
    	puts("MIT License: Copyright (c) 2016-2017 dd86k");
    	puts("Project page: <https://github.com/dd86k/wi>");
		return 0;
	}

	version (Windows) const string input = toLower(args[$ - 1]);
	else              const string input = args[$ - 1];

	char* p = getenv("PATH");

	string paths;
	if (p)
		paths = cast(immutable)fromStringz(p);
	else {
		puts("There was an error getting PATH.");
		return 1;
	}

	foreach (path; paths.split(DELIM))
	{
		try
		{
			ptrdiff_t i;
			//TODO: expand os variables
			debug if ((i = indexOf(path, VARC)) != -1)
			{
				version (Windows)
				{

				}
				version (Posix)
				{

				}
			}

			foreach (file; dirEntries(path, SpanMode.shallow))
			{
				version (Windows)
				{
					if (input == toLower(getBaseName(file.name)))
						puts(file.name.toStringz);
				}
				version (Posix)
				{
					if (input == getBaseName(file.name))
						puts(file.name.toStringz);
				}
			}
		}
		catch (FileException)
		{

		}
	}

	return 0;
}

/**
 * Gets the most basic filename out of a full path.
 * Theoretically works on linux with extension-less files.
 * Params: path = Path (full or incomplete)
 * Returns: Basic filename without extension.
 * Examples:
 *   C:\Cool\ABC.exe -> ABC
 *   /usr/share/e    -> e
 */
string getBaseName(string path) @nogc @safe pure
{
	size_t i = path.length;
	const size_t l = i; // total length

	while (path[--i] != DIRSEP && i >= 0) {}
	size_t s = ++i;
	while (path[i++] != '.' && i < l) {}

	return path[s .. i - 1];
}	