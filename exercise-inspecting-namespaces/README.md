## Inspecting namespaces

There is a process running `sleep 12` in a loop.

### General namespace questions:

- Is it running in the host ipc namespaces?
- Is it running in the host pid namespaces?
- Is it running in the host mount namespaces?

### Questions about the mount namespace

- Does it have the same root filesystem?
- How is the mount propagation configured?
- Are more files read-only or inaccessible? If so, how is it achieved?

### Questions about the network namespace

- Is it running in the host network namespaces?
- What network interfaces does it have access to?
- What are the current connections in that network namespaces? (tcp4, tcp6, unix sockets)

### Questions about the user namespace

- Is it running in the host user namespaces?
- If so, what's the user mapping applied?
- Create a new unprivileged user namespace

### Tools

- Reading /proc
- Using nsenter
- Using ip
- Using lsns
