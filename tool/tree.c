#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#define UNUSED __attribute__((unused))

#define MAX_DEPTH 10
#define DIR_PREFIX "📁 "
#define LINK_TREE
// #DEFINE SHOW_HIDDEN

#ifdef LINK_TREE
	#define EXPAND_TABS
	#define NO_EXT
#endif

// Print required indentation level
void indent(int depth) {
	for (int i = 0; i < depth; i++)
#ifndef EXPAND_TABS
		putchar('\t');
#else
		printf("        ");
#endif
}

// Print filename without extension
void no_ext(char *filename) {
	for (int i = 0; i < (int)strlen(filename); i++) {
		if (filename[i] == '.')
			break;
		putchar(filename[i]);
	}
}


// String Replace {{{
char *str_replace(char *orig, char *rep, char *with) {
    char *result; // the return string
    char *ins;    // the next insert point
    char *tmp;    // varies
    int len_rep;  // length of rep (the string to remove)
    int len_with; // length of with (the string to replace rep with)
    int len_front; // distance between rep and end of last rep
    int count;    // number of replacements

    // sanity checks and initialization
    if (!orig || !rep)
        return NULL;
    len_rep = strlen(rep);
    if (len_rep == 0)
        return NULL; // empty rep causes infinite loop during count
    if (!with)
        with = "";
    len_with = strlen(with);

    // count the number of replacements needed
    ins = orig;
    for (count = 0;( tmp = strstr(ins, rep)); ++count) {
        ins = tmp + len_rep;
    }

    tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);

    if (!result)
        return NULL;

    // first time through the loop, all the variable are set correctly
    // from here on,
    //    tmp points to the end of the result string
    //    ins points to the next occurrence of rep in orig
    //    orig points to the remainder of orig after "end of rep"
    while (count--) {
        ins = strstr(orig, rep);
        len_front = ins - orig;
        tmp = strncpy(tmp, orig, len_front) + len_front;
        tmp = strcpy(tmp, with) + len_with;
        orig += len_front + len_rep; // move to next "end of rep"
    }
    strcpy(tmp, orig);
    return result;
}
// }}}

void print_dir(char *path, int depth) {

	indent(depth);
	printf("%s%s/\n", DIR_PREFIX, basename(path));

	if (depth >= MAX_DEPTH) {
		return;
	}

	DIR *directory = opendir(path);
	struct dirent *entry;
	while ((entry = readdir(directory)) != NULL) {
			char *full_path = malloc(sizeof(path) + sizeof(entry->d_name));
		
			strcpy(full_path, path);
			strcat(full_path, "/");
			strcat(full_path, entry->d_name);

		if (entry->d_type == DT_DIR) {

#ifdef SHOW_HIDDEN
			if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
#else
			if (strncmp(entry->d_name, ".", 1) == 0) { 
#endif
				continue;
			}
			print_dir(full_path, depth+1);
		} else if (entry->d_type == DT_REG) {
			indent(depth+1);
#ifndef NO_EXT
			printf("%s\n", entry->d_name);
#else
#ifdef LINK_TREE
			char* x = str_replace(full_path, ".fmt.txt", ".html");
			char* y = str_replace(x, "src/", "out/");
			printf("<a href=\"%s\">", x);
			free(x);
			free(y);
#endif
			no_ext(entry->d_name);
#ifdef LINK_TREE
			printf("</a>");
#endif
			putchar('\n');
#endif
		}
			free(full_path);
	}
	closedir(directory);
}

int main (UNUSED int argc, char ** argv) {
	char *dir = argv[1] ? argv[1] : get_current_dir_name();
	print_dir(dir, 0);
	if (argv[1] == NULL)
		free(dir);
}
