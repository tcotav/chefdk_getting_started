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

    name             'jdemo'
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

    $ berks install
    Resolving cookbook dependencies...
    Fetching 'jdemo' from source at .
    Fetching cookbook index from https://api.berkshelf.com...
    Using java (1.22.0)
    Using jdemo (0.1.0) from source at .
    Using openssl (1.1.0)
    Using tomcat (0.15.12)

Time for happy dance.  It worked.  Commit metadata.rb changes into git.

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


### Run Kitchen after some changes -- different node convergeance.

Now we're going to see if what we put into place will work -- we'll use the converge command to once again spin up the chef run on the node.  This time though, we gave the recipe something to do.  Several somethings in fact as you'll see from the output of the following command:

  $ kitchen converge

Well I'm not going to lie -- that command just exploded all over my console.  TO THE WET WIPES!

(Some time later...)

It didn't particularly like installing openjdk-6.  Maybe it was some transient failure?  Ideally, I'd be using jdk 7 anyway.

Wow -- this is a lot of stuff to install.

       0 upgraded, 88 newly installed, 0 to remove and 5 not upgraded.
       Need to get 66.4 MB of archives.

Failed on retrieving something from the repo, fwiw.  Not my problem and yet -- totally my problem.  Let's try to force jdk 7.  How do we do something like that?  A good place to look is the README.md of the cookbook we're fiddling with.  In this case, java.

### OMFG things went AWRY

So we need to try to install a different version of java.  We probably should've done this at the start, but we were lazy.  So, first we go to the chef cookbook community site and look up java.


Community Cookbook site link to [Java Cookbook](http://community.opscode.com/cookbooks/java).  This is scenic and all that.  Some pictures of funny looking people over in the right hand column.  We want to look at [this cookbook on github](http://community.opscode.com/cookbooks/java).

(this is a hoot, isn't it?)

On the java cookbook github page, scroll down to the README.md.  There we find the usage that we're looking for.  There's all kinds of stuff there that we could configure, but all we really want is `openjdk` version `7`.

in the `Attributes` section, we find attributes that match what we want.  They are:

node['java']['install_flavor'] = 'openjdk'    # this is the default, but humor me
node['java']['jdk_version'] = '7'

Ok, great.  We've got those, but where do they go in our recipe?  We need to put them into the file that doesn't exist -- `attributes/default.rb`

So we create it in the root of the jdemo cookbook directory and put those two lines into it.  Check any outstanding changes into git.


