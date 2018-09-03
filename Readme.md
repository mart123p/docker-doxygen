# Docker Doxygen

This container aims to generate doxygen documentation automatically. It works best when using a git hook to make a curl request to a specific url to this container. Once the get request is received, Doxygen's html documentation will be updated and hosted on this container using [Nginx](https://www.nginx.com/).

## How to run this image
```Console
$ docker run --name doxygen-project-name -v /some/path/:/var/data/ -e GIT_REPO=https://git_url -p 8000:80 mart123p/docker-doxygen
```
This is the minimum to run the container. However, there are many more parameters to configure to the container. They are all listed below.

### Parameters
Parameter | Description | Example
--- | --- | ---
GIT_REPO | The url of the git repository you wish to fetch from. It can also be ssh. | `-e GIT_REPO=https://github.com/mart123p/docker-doxygen.git`
API_KEY | The key that needs to be supplied to the hook to authenticate the Get request. If not set it will be generated automatically. | `-e API_KEY=MySecureKeyThatNoOneWillGuess`
OUT_DIR | The output directory of the Doxygen generated documentation. | `-e OUT_DIR=doxygen-output`
SRC_DIR | The root directory where doxygen needs to be run. It will look for a Doxyfile. If it's not present it will use it's default Doxyfile which is available [here](https://github.com/mart123p/docker-doxygen/blob/master/doxygen/Doxyfile).| `-e SRC_SIR=src/project`
USERNAME | Enables basic auth on the doxygen documentation. This parameter needs to be used with PASSWORD. | `-e USERNAME=admin`
PASSWORD | Enables basic auth on the doxygen documentation. This parameter needs to be used with USERNAME. | `-e PASSWORD=admin`

### Using SSH to connect to git
You may want to connect to git via ssh. In order to do so, you will need to have an ssh key pair. This container will automatically generate a public/private key for you. You can find the public key used for ssh authentication in the following path `config/id_rsa.pub`  (`config/id_rsa` for the private key).

If you want to use your own ssh keys you can replace the two files with your own. You have to make sure that the permissions of your new ssh keys are the same as the original.

## Git Hook Configuration
In order to launch automatically the generation of Doxygen's documentation you must set up a git hook. It should be a git hook post-receive on the git server. You can do something similar with github and it does not require scripting .


Inside the git hook, you will need to make a get request to the following url.
```
http://localhost:8000/cgi/hook.cgi?key=API_KEY
```
Please note, basic auth is not enabled on this url as it already needs a key to be accessed.