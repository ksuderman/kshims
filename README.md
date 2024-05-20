# Kshim : a simple shim for kubectl and helm 

A kubeconfig file may contain multiple contexts, each with its own configuration. One drawback of having multiple contexts in one file is the file is global and can only be set to one context at a time.  That means any invocation of `kubectl` or `helm` on the system will use the same context.  This can be a problem if you need to work with multiple clusters or namespaces.  

A *shim* is a small library that transparently intercepts API calls and changes the arguments passed, handles the operation itself, or redirects the operation elsewhere.  In this case, the `shim` script intercepts the `kubectl` and `helm` commands, sets the KUBECONFIG environment variable, and then redirects the call to the real `kubectl` or `helm` command. The `kshim` script allows you to easily switch between contexts by creating a symbolic link to the desired kubeconfig file, while the `shim` script does the actual work of setting the KUBECONFIG environment variable and then calling the `kubectl` or `helm` command. Users will only need to interact the `kshim` script.

## Installation

TBD

## Manual Installation

1. Create a directory for the `kshim` script and the `shim` script. The default directory is `~/.kube/bin`. If you use another directory, replace `~/.kube/bin` with the appropriate directory in the following steps.
2. Copy the `kshim` script and the `shim` script to the directory created in step 1.
3. Run `chmod +x ~/.kube/bin/kshim ~/.kube/bin/shim` to make the scripts executable.
4. Run `~/.kube/bin/kshim init >> ~/.bash_profile` to add `ksim` to the PATH.
5. Restart your shell or run `source ~/.bash_profile` to update the PATH.

**Note**: If you use a different shell, replace `~/.bash_profile` with the appropriate file for your shell.

Now create shims for the `kubectl` and `helm` commands:

```bash
kshim link kubectl
kshim link helm
```

Verify your installation by running `kubectl confess` and/or `helm confess`. If the installation is successful, you will see the following message:

```bash
This is the kshim wrapper for /usr/local/bin/kubectl
```

The path to the real `kubectl` or `helm` command will be displayed in the message and will depend on your system configuration.

### Notes

The `kshim init` command will also create an alias `alias k=kshim` for you.  You will need to edit your profile if you do not want this bevavior. Any commands that are not recognized by `kshim` will be passed to the real `kubectl` command unchanged so you can do things like: `k get pods -A`.

## Commands

- **cat** *kubeconfig*<br/>
    Display the contents of the kubeconfig file
- **clear**<br/>
    Removes the ~/.kube/config symlink
- **global** *name*<br/>
    Sets the global kubeconfig by symlinking ~/.kube/config
    to ~/.kube/configs/*name*
- **init**<br/>
    Prints the statements needed to intialize the kshim system.<br/>
    `$> kshim init >> ~/.bash_profile`
- **install** [-m|--move] *name* [/path/to/kube/config]<br/>
    Copies the kubeconfig (~/.kube/config) to ~/.kube/configs/*name*
    Use the --move option to remove the original kubeconfig, otherwise a
    copy is made in $HOME/.kube/configs/.
- **link** *name*<br/>
    Creates a new shim for *name*
- **list**, **ls**<br/>
    List available contexts
- **local** *name*<br/>
    Creates the .kubeconfig symlink in the current directory that points to
    ~/.kube/configs/*name*.  When running kubectl through the shim (recommended)
    the local .kubeconfig kubeconfig will be used.
- **login** [*namespace*] *container*<br/>
    Uses kubectl exec to open a Bash shell in the given pod/container. Only enough of the container ID to be unique is needed.<br/>
    `$> k login my-namespace my-pod`<br/>
    `$> k login job`
- **namespace**<br/>
    Sets the default namespace for the current kubectl context
- **paste** *name*<br/>
    Pastes the contents of the clipboard to ~/.kube/configs/*name*. (MacOS only)
- **rm** <kubeconfig><br/>
    Deletes the kubeconfig file
- **unlink** *name*<br/>
    Removes the shim for *name*
- **help**<br/>
    Prints this help message.

## Usage

```bash
# Installs the default kubeconfig file (~/.kube/config) after creating a new cluster
k install my-cluster
# Installs a kubeconfig file for a new cluster from a different location
k install my-cluster /path/to/kube/config

# Creates a new shim for kubectl and helm. This only needs to be done once when installing kshim
k link kubectl
k link helm

# Deletes the shims for kubectl and helm
k unlink kubectl
k unlink helm

# Sets the global kubeconfig file
k global my-cluster

# Sets the local kubeconfig file
k local my-cluster

# Sets the default namespace for the current kubectl context
k namespace my-namespace
k get pods

# Lists available contexts
k ls
k list

# Opens a Bash shell in the given pod/container
k login my-namespace my-pod
# Or if the namespace has been set as above
k login my-pod

# Removes the ~/.kube/config symlink. Use -f if ~/.kube/config is not a symlink
k clear
k clear -f

# Deletes the kubeconfig file from ~/.kube/configs
k rm my-cluster

# Pastes the contents of the clipboard to ~/.kube/configs/*name* (MacOS only)
k paste my-cluster

# Prints the contents of the kubeconfig file
k cat my-cluster

# Prints the statements needed to initialize the kshim system
k init >> ~/.bash_profile

# Prints the help message
k help

# Use kubectl and helm as you normally would. These will use the local kubeconfig file, if defined.
kubectl get pods
helm install galaxy -n galaxy galaxy/galaxy 
```
## How it works
Kshims work by looking for a symbolic link named `.kubeconfig` in the current directory or if `~/.kube/confg` is a symbolic link. If the symbolic link is found, the `shim` script will set the KUBECONFIG environment variable to the target of the link and then call the real `kubectl` or `helm` command. If the symbolic link is not found, the `kshim` script will call the real `kubectl` or `helm` command without setting the KUBECONFIG environment variable.

Kubeconfig files are stored in the `~/.kube/configs` directory. It is **strongly** recommended to use one kubeconfig file per cluster. The `kshim` script can create a symbolic link named `.kubeconfig` in the current directory that points to the kubeconfig file in the `~/.kube/configs` directory. Ot the `kshim` script can also create a symbolic link named `~/.kube/config` that points to the kubeconfig file in the `~/.kube/configs` directory.