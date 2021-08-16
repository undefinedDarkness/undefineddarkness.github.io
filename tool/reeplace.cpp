#include <iostream>
#include <sstream>

/* The only reason this exists is that I had a stupid hard time doing it
 * all I wanted was simple string replacement but everything overcomplicated way too much
 * and sed / perl have escaping issues */

void replaceAll(std::string& str, const std::string& from, const std::string& to) {
	if(from.empty())
		return;
	size_t start_pos = 0;
	while((start_pos = str.find(from, start_pos)) != std::string::npos) {
		str.replace(start_pos, from.length(), to);
		start_pos += to.length(); 
	}
}

int main (int argc, char ** argv) {
	std::ostringstream std_input;
	std_input  << std::cin.rdbuf();
	std::string data = std_input.str();
	replaceAll(data, argv[1], argv[2]);
	std::cout << data;
}
