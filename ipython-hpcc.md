# IPython Notebook on the HPCC

## Installing

1. Go to http://continuum.io/downloads and copy the link for Linux 64-bits installer. At the time of this writing it is
http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.1-Linux-x86_64.sh

2. Go to HPCC and download the file

   ``` bash
   $ wget -c http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.1-Linux-x86_64.sh
   ```

3. Install Anaconda

   ``` bash
   $ bash Anaconda-1.9.1-Linux-x86_64.sh
   ```
   
  1. Accept the license
  2. Choose an installation directory (default is fine)
  3. Don't add to default path at the end of installation

4. Configure modules

  User created modules are a great way to organize software installation on HPCC.  Create a modulefiles directory in your home dir:

   ``` bash
   $ mkdir -p ~/modulefiles
   ```

   Let's  configure a modulefile for Anaconda. This goes in ~/modulefiles/anaconda.lua

   ``` lua
  -- -*- lua -*-
  help(
  [[
  Anaconda Python distribution
  ]])

  -- comments are prefaced with two dashes

  whatis("Description: Anaconda")
  whatis("URL: continuum.io/anaconda")

  local install_path = "/mnt/home/<username>/anaconda"

  -- set an environment variable
  setenv("ANACONDA_HOME",install_path)

  -- add to PATH variable
  prepend_path('PATH', pathJoin(install_path,"bin"))

  -- add Library Paths
  prepend_path('LD_LIBRARY_PATH',pathJoin(install_path,"lib"))
  prepend_path('LIBRARY_PATH',pathJoin(install_path,"lib"))

  -- add include paths
  prepend_path('INCLUDE',pathJoin(install_path,"include"))
  ```

  Note that you need to change `<username>` above!

  To use our new modulefile you need to tell the module system to check our modulefile directory.

   ``` bash
   $ module use ~/modulefiles
   ```

   After that we can load Anaconda:

   ``` bash
   $ module load anaconda
   ```

## Configuring notebook server

1. Create the ipython config dir

  ``` bash
  $ mkdir -p ~/.ipython
  ```

2. Create a new profile (nbserver, for example)

  ``` bash
  $ ipython profile create nbserver
  ```

3. Generate a self-signed certificate for SSL

  ``` bash
  $ openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ~/.ipython/profile_nbserver/security/mycert.key -out ~/.ipython/profile_nbserver/security/mycert.crt
  ```

4. Create a password. The output will be used in the next step.

  ``` python
  >>> from IPython.lib import passwd; passwd()
  Enter password: 
  Verify password: 
  'sha1:1d2f94d56c5c:9f15276425979d0bbc87ba1bc530e5e1b25ea100'
  ```

4. Edit the nbserver profile configuration for IPython notebook

  ``` bash
  $ vi ~/.ipython/profile_nbserver/ipython_notebook_config.py
  ```

  File content:

  ``` python
  c = get_config()
  c.NotebookApp.open_browser = False
  c.NotebookApp.certfile = u'/mnt/home/<username>/.ipython/profile_nbserver/security/mycert.crt'
  c.NotebookApp.profile = u'nbserver'
  c.NotebookApp.password = u'sha1:1d2f94d56c5c:9f15276425979d0bbc87ba1bc530e5e1b25ea100'
  c.NotebookApp.keyfile = u'/mnt/home/<username>/.ipython/profile_nbserver/security/mycert.key'
  ```

  Note that you need to change `<username>` above!

## Running a notebook server

1. Log into one of the dev- machines (dev-intel10 in this case).

  ``` bash
  $ ssh -t hpcc.msu.edu "ssh dev-intel10"
  ```

2. Use tmux to start to start IPython notebook with the nbserver profile:

  ``` bash
  $ tmux  ## or "tmux attach"
  $ ipython notebook --profile=nbserver
  ```

3. In your computer,

  ``` bash
  $ ssh -t -L 8888:localhost:7000 hpcc.msu.edu "ssh -L 7000:localhost:8888 dev-intel10"
  ```

4. Go to https://127.0.0.1:8888

Why do this work? Let's break down the command to make it easier to understand:

``` bash
$ ssh -t -L 8888:localhost:7000 hpcc.msu.edu "ssh -L 7000:localhost:8888 dev-intel10"
```

1. The first part:

  ``` bash
  $ ssh -t -L 8888:localhost:7000 hpcc.msu.edu
  ```

  connects to hpcc (gateway machine), redirecting port 7000 from gateway
  to our host port 8888

        +------------+    +--------------+
        | localhost  |    | gateway@hpcc |
        |------------|    |--------------|
        |   8888     |+-->|     7000     |
        +------------+    +--------------+
     
  More details:
  http://explainshell.com/explain?cmd=ssh+-t+-L+8888%3Alocalhost%3A7000+hpcc.msu.edu

2. The second part:

  ``` bash
  $ ssh -L 7000:localhost:8888 dev-intel10
  ```

  connects to dev-intel10 and redirect port 8888 (where the IPython
  notebook is running) from dev-intel10 to gateway port 7000

      +--------------+    +--------------+
      | gateway@hpcc |    | dev-intel10  |
      |--------------|    |--------------|
      |     7000     |+-->|   8888       |
      +--------------+    +--------------+

  More details:
  http://explainshell.com/explain?cmd=ssh+-L+7000%3Alocalhost%3A8888+dev-intel10

In the end, we have

     +------------+    +--------------+    +--------------+
     | localhost  |    | gateway@hpcc |    | dev-intel10  |
     |------------|    |--------------|    |--------------|
     |   8888     |+-->|     7000     |+-->|   8888       |
     +------------+    +--------------+    +--------------+

and that's why we connect to https://127.0.0.1:8888

The command might look weird because SSH has an argument which is not used normally. After the host you can send a command to be run remotely, and I'm using this to chain two SSH commands. If you want to get really fancy you can chain even more, but I think it is already confusing enough =P

## Easy way to use IPython.parallel with Torque

  There is a Python module called [cluster_helper][1] which abstracts the usage of IPython.parallel.
  Install it with

  ```bash
  $ pip install ipython-cluster-helper
  ```

  Once installed you can use it as a context manager. For example

  ```python
  from cluster_helper.cluster import cluster_view

  def long_running_function(n):
      machine_name = !uname -a
      return (n * 2, machine_name)

  with cluster_view(scheduler="torque", queue="main", num_jobs=5, 
                    extra_params={'resources': "walltime=01:00:00;account=ged-intel11;mem=64mb"}) as view:
      result = view.map(long_running_function, range(200))
  ```
  
  - scheduler and queue will always be the same ('torque' and 'main').

  - num_jobs: how many parallel jobs will be executed. 
    There is a hard limit of 512 in our HPCC, but usually you don't need that much: these jobs can be reused
    once tasks are finished. In this example I'm using five jobs, but running 200 tasks!

  - extra_params: this is not so well documented, but you can pass the PBS resources list in this param.
    You can check the [HPCC docs][3] for more info, but important ones are:

      - walltime: how much time the job will take to execute. Remember! The job is killed after this period!

      - account: we can use 'ged-intel11' to have priority in the 1TB RAM machine.

      - mem: how much memory the job will use.

  Tip: since we are using IPython, the '!' syntax works, and you can execute shell commands (see the example).

  [Complete example with output][2]

## Table of contents extension

https://github.com/minrk/ipython_extensions#table-of-contents

## References

https://wiki.hpcc.msu.edu/display/hpccdocs/User+Created+Modules

http://ipython.org/ipython-doc/stable/interactive/public_server.html

http://nbviewer.ipython.org/github/ipython/ipython-in-depth/blob/master/notebooks/Running%20a%20Secure%20Public%20Notebook.ipynb

[1]: https://github.com/roryk/ipython-cluster-helper
[2]: http://nbviewer.ipython.org/gist/luizirber/e5fd8d7b8310aa1f05fc
[3]: https://wiki.hpcc.msu.edu/display/hpccdocs/Scheduling+Jobs#SchedulingJobs-qsuboptions
