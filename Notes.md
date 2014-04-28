## Dev starter using ChefDK bits

### Get your project started using new chef command

    $ chef generate cookbook jdemo

Take a peek at what you've done.

    $ ls jdemo
    Berksfile	README.md	metadata.rb
    chefignore	recipes

### Get going with git immediately.

I'm a fan of git flow -- [Git Flow](https://github.com/nvie/gitflow)

Change to your jdemo directory and then:

    $ git flow init

I use the defaults for git flow.


I prefer using git flow as it keeps me in a pretty good workflow.  Right after init, it drops me into the develop branch.

    $ git branch
    * develop
    master

(If you're in git, then just:  `$ git init` )

Then do the initial commit:

    $ git add -A
    $ git commit -m "initial commit"

Git sanity check:

    $ git status
    # On branch develop
    nothing to commit, working directory clean

And we're golden.  Next: test kitchen


### setting up test kitchen

With ChefDK installed, you've got test-kitchen all ready installed.  We're going to use it to write some tests for the cookbook that we're going to write in the latter steps so first things first.

Test drive the kitchen command:

    $ kitchen

The docs on test-kitchen are awesome by the way -- [http://www.kitchen.ci].  I'd recommend taking a run through that tutorial.


### kitchen.yml -- configuring test kitchen

The new `chef` tool though already set us up to run kitchen.  In your basedir, you'll find the file .kitchen.yml

`.kitchen.yml`

    ---
    driver:
      name: vagrant

    provisioner:
      name: chef_solo

    platforms:
      - name: ubuntu-12.04
      - name: centos-6.4

    suites:
      - name: default
        run_list:
          - recipe[bar::default]
        attributes:



So by default, the `chef` app set you up to use [Vagrant](http://vagrantup.com) with the default of [Virtualbox](http://virtualbox.org) as your VM environment and including two vms: one centos and one ubuntu.

We can confirm those by running the command as follows:

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
    default-centos-64    Vagrant  ChefSolo     <Not Created>

For general cookbook development, you'd want to hit up both the RH family and debian, but for now, we'll just use ubuntu.  Remove the line for centos

      - name: centos-6.4

and test again:

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>

Leaving just one vagrant box to install.

We have one more change to make to the `.kitchen.yml` file -- changing the run_list that we want applied to our soon-to-be-created-and-launched node.

Change this:

    run_list:
      - recipe[bar::default]

To this:

    run_list:
      - recipe[jdemo]

Do a quick check-in of the change into git.

    $ git add .kitchen.yml
    $ git commit -m "updated kitchen yml -- 1 platform"

and then let's give it a shot:

    $ kitchen create all
    -----> Starting Kitchen (v1.2.1)
    -----> Creating <default-ubuntu-1204>...


And off it'll go.  I already have the vagrantbox for `ubuntu-1204` sitting around so that'll cut the run time of the command.  What is going on here is that kitchen is kicking off a `vagrant up` for the `ubuntu-1204` host image.  If you don't have it on your host, it will go out and retrieve it from the magical glorious intarwubz.  This might take a while.  Then it will bring up the host in normal vm fashion.

We can confirm our work with the following command:

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1304  Vagrant  ChefSolo     Created



Note that the `Last Action` column changed from `<Not Created>` to `Created`.

Okay...  so now what?

### Kitchen converge

    $ kitchen converge

First you'll see it head out and grab the chef installer and install it on our ubuntu-1204 node.  I had an error (documented changing the cookbook name in `.kitchen.yml` without ACTUALLY changing the file...

If you run into any errors or problems, I'd recommend a good solid 10 minutes of hysterical sobbing followed by reading the error message and logs.

Invariably the chef client will run.  We don't have it doing anything yet so it is a bit anticlimactic.  We did change the state of the node to `Converged` though... so we got that going for us (which is nice).

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1204  Vagrant  ChefSolo     Converged


### Do Something!

Hopefully you didn't start reading this late at night as you'll never be able to sleep with all this excitement.  Now we're going to do a bit of pure chef stuff.  The app we're writing is to set up a tomcat instance and drop a (canned) war into it along with a few other files.

What do we need to do that?  First, lets add a few public cookbooks: `tomcat`, `java`

Normally we'd start dicking around with a Gemfile to get `Berkshelf` installed to magically manage our cookbook dependencies, but `Berkshelf` is another component native to `chefdk` so yay team.


Further, if you look inside the cookbook directory (where we'll be doing all of our custom cookbook work), you'll find the `jdemo` cookbook stubbed out for us by `chefdk`.


Inside that cookbook directory, you'll see

    $ ls
    Berksfile	chefignore	metadata.rb	recipes

We're not going to do anything with Berksfile.  It looks like this stubbed out:

`Berksfile`

    source "https://api.berkshelf.com"

    metadata

We use Berkshelf to help us manage cookbook dependencies.  Like we need tomcat for our cookbook.  Tomcat needs java.  This file though tells Berkshelf to defer to the `metadata.rb` file for its requirements.  We'll look at that file now.

`metadata.rb`

    name             ''
    maintainer       ''
    maintainer_email ''
    license          ''
    description      'Installs/Configures '
    long_description 'Installs/Configures '
    version          '0.1.0'


Well, a whole lot of nothing going on there.  Not even my name, email address, or licensing...  Anyway, functionally we don't need that.  What we NEED to do is tell Berkshelf what cookbooks we're going to need for our custom recipe.

At the bottom, we add the line:

    depends "tomcat"

Oooookay, let's have a go with that.  We're going to run Berkshelf and tell it to go and get all of the dependencies for the tomcat cookbook.

At the command line:

    $ berks
    Ridley::Errors::MissingNameAttribute The metadata at '~/jdemo/cookbooks/jdemo' does not contain a 'name' attribute. While Chef does not strictly enforce this requirement, Ridley cannot continue without a valid metadata 'name' entry.


Sigh... so maybe this'll get fixed in some codegen somewhere, but its my bad for not taking my time and filling out the fields in metadata.rb.  So, let's put `jdemo` in the name field of `metadata.rb` and try again with `berks install`.

    $ berks install
    Resolving cookbook dependencies...
    Fetching 'jdemo' from source at .
    Fetching cookbook index from https://api.berkshelf.com...
    Installing java (1.22.0)
    Using openssl (1.1.0)
    Installing tomcat (0.15.12)
    Using jdemo (0.1.0) from source at .

Time for happy dance.  It worked.

What happened?  Well, using the Power of Berkshelf (tm) we imported cookbooks and dependencies by just including the name of the desired cookbook in the metadata.rb and then invoking the `berks` command to install them.  If you want to go and confirm that these new cookbooks are around, you can do a

    $ ls ~/.berkshelf/cookbooks
    java-1.22.0
    openssl-1.1.0
    tomcat-0.15.12

For the full description and docs on berkshelf, please go [to the website](http://www.berkshelf.com).

We've got our supporting cookbooks.  Now let's take a little step to using them.

### First Cookbook Recipe

If we run our kitchen job again, it will run the chef client on our virtual node.  It will use the runlist we specified in the `.kitchen.yml` but it still won't do anything.  Why's that?  Because we haven't done anything with the default recipe in jdemo.  Let's crack that file at:

`cookbooks/jdemo/recipes/default.rb`

The file currently only has comments (the hash (#) denotes a comment line in these files).  So at the end of the file add this line:

    include_recipe 'tomcat'

Close and write the file.

Do a quick check-in to git (because that's how we all roll and we're on the dev branch after all...)

Huh... so apparently, cookbooks or rather /cookbooks are part of the default .gitignore dropped by chef generate app <name>.  So I'm going to edit that, but I'm wondering if its supposed to magically pull the cookbooks from other local repo rather than have me WRITING them in the created subdir...

Fix -- remove line, `cookbooks/` from .gitignore and then import the entire cookbook subdirectory.

### Run Kitchen after some changes -- different node convergeance.

$ kitchen converge




