import std.stdio;
import core.stdc.stdlib : getenv;
import std.string : toLower, fromStringz, split;
import std.file : DirEntry, dirEntries, SpanMode, FileException;

version (Windows) {
	enum DELIM = ';';
	enum DIRSEP = '\\';
}
version (Posix) {
	enum DELIM = ':';
	enum DIRSEP = '/';
}

/**
 * Entry point.
 * Params: args = CLI Arguments.
 * Returns: Error code.
 */
int main(string[] args)
{
	if (args.length == 1)
	{
		writeln("Search directories in PATH.");
		writeln("Usage:");
		writeln("  wi <String>");
		return 0;
	}

	version (Windows) const string input = toLower(args[$ - 1]);
	else              const string input = args[$ - 1];

	char* p = getenv("PATH");
	
	string paths;
	if (p)
		paths = cast(immutable)fromStringz(p);
	else {
		writeln("There was an error getting PATH.");
		return 1;
	}

	foreach (path; paths.split(DELIM))
	{
		try
		{
			foreach (file; dirEntries(path, SpanMode.shallow))
			{
				version (Windows) if (input == toLower(getBaseName(file.name)))
				{
					writeln(file.name);
				}
				version (Posix)   if (input == getBaseName(file.name))
				{
					writeln(file.name);
				}
			}
		}
		catch (FileException)
		{ //TODO: Expand variables (getenv)

		}
	}

	return 0;
}

/**
 * Gets the most basic filename out of a full path.
 * Params: path = Path (full or incomplete)
 * Returns: Basic filename without extension.
 * Examples:
 *   C:\Cool\ABC.exe -> ABC
 *   /usr/share/e    -> e
 */
string getBaseName(string path) @nogc @safe
{
	size_t i = path.length;
	const size_t l = i; // total length
	size_t s;

	while (path[--i] != DIRSEP && i >= 0) {}
	s = ++i;
	while (path[i++] != '.' && i < l) {}

	return path[s .. i - 1];
}	