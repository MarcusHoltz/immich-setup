# Immich Setup Scripts

Here are all of the things I had to do to get Immich at a point where users, and myself, could start to enjoy using it.

For the blog post that goes along with this guide, visit: [https://blog.holtzweb.com/posts/complete-immich-docker-setup-guide-configuration](https://blog.holtzweb.com/posts/complete-immich-docker-setup-guide-configuration)


* * *

## Hi, I'm new to Immich

Hello. Welcome. 

I presume you're here because you want out of a proprietary cloud-based photos/videos/memories system.

[Immich](https://www.reddit.com/r/immich/) is a good Google Photos or iCloud Photos alternative, and still allows sharing between multiple users. It may just be easy enough for your parents.

It is not just a good iCloud/Google Photos replacement, in many aspects, it does much more.


* * *

## Getting Immich Up and Running

What all does this tutorial cover?

- [Install](#first-step-install)

- [Import Files](#second-step-immich-import)

- [Dealing with duplicate files](#third-step-immich-stack)

- [Keeping your Immich library at a manageable size](#fourth-step-immich-compress)


Let's go!


* * *

## Immich: The Line in the Sand

How Immich works, you need to pick one of these two:

1. [Make changes outside of Immich, import your existing folders](https://immich.app/docs/guides/external-library/)

2. [Transfer your current folders full of photos to an Immich library](https://immich.app/docs/features/command-line-interface/)

This sounds like they're the same thing, right? NO!


* * *

### 1. Import your folders full of photos

The first option, `Make changes outside of Immich, import your existing folders`, does not move your files. They stay where they're at and appear in Immich. 

> This option is referred to as an External Library in Immich.


* * *

### 2. Transfer your photos to an Immich library

The second option, `Transfer to an Immich library`, is the one this tutorial is using. The whole point of me moving to Immich is to not have to rely on folders again, but be able to find things directly through Immich. My folders will still be there, but present as `Albums` inside of Immich. 

> You will need to import your photos to Immich. This is an extra process as you're sending data into Immich, not just pointing to an External Library.


* * *

### Why transfer files to an Immich library?

I am going to transfer photos to an Immich library, letting Immich handle all of the organization of my files. 

We won't ever need to create new folders to sort our media; all of it is available in Immich, just search it.

This is the start of the entire process. How will you store your photos?

**Why manage External Libraries for family and friends, when you could transfer those files from shared folders to a centralized location?**

I will be importing into the system Immich uses to organize files. The folder structure can be changed in the future and Immich can re-folder your files.

- `My meme folders` - not in Immich. (use [Meme-search](https://github.com/neonwatty/meme-search))

- `All of my documentation screen shots` - not in Immich. (use [Holtzweb Blog](https://blog.holtzweb.com/))

- `All of my receipts, manuals, invoices, pdfs` - not in Immich. (use [Papra](https://github.com/papra-hq/papra) or [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx))

- `Smokie's Birthday Photos` - in Immich.

Yes, you could send all that to Immich, and have it available to search -- but **this** is a *shared Immich instance* for family, not a general dumping ground.

Each user will have the same folder structure. Any organization is done by Immich in [albums](https://github.com/simulot/immich-go#from-folder-sub-command).


* * *

## First step: Install

I have most of my long term and speedy storage on UnRAID. 

Immich will reside on the UnRAID server, no point of having the service up if the files are unavailable.

Immich has a very good [Unraid starter template](https://immich.app/docs/install/unraid) for us to use. This write-up assumes you've already had a go at that. 

If not, give the [Immich on Unraid: Docker-Compose Method](https://immich.app/docs/install/unraid) official documentation from Immich a read.

I will be using that as a base for the files in this tutorial. 


### Copy my files, make a few edits

You can find the files we will be using, the same I use on my UnRAID server, in my:

- [UnRAID Immich Setup Repo](https://github.com/MarcusHoltz/immich-setup/tree/main/unraid-immich-compose).

> To setup - if you're not using UnRAID - the [docker-compose.yml](https://github.com/MarcusHoltz/immich-setup/blob/main/unraid-immich-compose/compose.manager/projects/immich/docker-compose.yml) and [env](https://github.com/MarcusHoltz/immich-setup/blob/main/unraid-immich-compose/compose.manager/projects/immich/env) files will work just fine.


* * *

## Second step: Immich Import

Now that you have Immich up and running, you need to load some content into Immich.

Without using External Libraries, you need to find a way to upload your images to Immich.

When importing your already saved folders into Immich you will need an API already generated and ready for each user.

This will be easy when using your cell phone, just login, the mobile app asks you what folders and BAM they're on the server.

> But what are we going to do with our old photo archive and Google Takeout photos?


* * *

### Importing Folders as Albums

Make sure you're using albums properly. 

This is how your phone will work too. Whatever folder your photos reside it, an album will be created.

So on a standard Android phone, you will have at-least one Album called `Camera`. The DCIM folder has the Camera folder, the standard folder for dumping your Camera apps photos into.

After that things like, `Downloads`, `Telegram Images`, `Telegram Video`, `Telegram Documents`, etc it's all up to you.

But make sure, if you're doing the desktop sync, that these folders make sense in a logical manner, and accompany the albums you're using on your mobile device.


* * *

### Immich-GO

Immich-GO is a single binary you can slap anywhere and then start importing.

It is soooooo easy. You could be on a remote server with a remote mount, no problem. Slap that binary in there, issue the command - done. No changes to the remote machine, nothing installed.

There is even a Python based GUI you could use: [Immich-Go GUI](https://github.com/shitan198u/immich-go-gui)


* * *

### All of the commands are on --dry-run

All of the commands you see below have the `--dry-run` flag active on them.

**There will be no changes made.**

You must remove the `--dry-run` part of the command to make changes. What you see on your screen will only be a representation of the changes that can be made.


* * *

#### Immich-GO (expects subfolders)

This will work in the current directory, assuming you have your folders there and the immich-go binary. But it will also "join folders" - what this means is if you have a bunch of subdirectories `/some/stuff/here/for/my/specific/purpose` - there are no sub-albumns in Immich. You need to flatten that structure. If you flatten it, what do you want it to look like? `some-stuff-here-for-my-specific-purpose`. And pictures in the `/some/stuff/here` directory will be in the album, `some-stuff-here`. The album-path-joiner flag at then end takes `/` and replaces them with `-` ... this is the same as `sed 's/\//-/g'`


```bash

MY_IMMICH_API_KEY=Xf9Lm2QzT8VwJpN0bYRsCk5HaHaHad7Ue3xWjF4gZt1Ao; \
./immich-go upload from-folder --dry-run \
  --pause-immich-jobs=FALSE \
  --api-key $MY_IMMICH_API_KEY \
  --server http://172.21.8.111:2283 \
  --recursive . \
  --folder-as-album FOLDER \
  --album-path-joiner "-"

```


* * *

#### Immich-GO (Google Takeout)

Here is another example, let's import our photos from a recent Google Takeout we downloaded, but oh no. 

We're on a remote Windows machine - download the binary!


```bash

.\immich-go.exe upload from-google-photos `
  --server http://172.21.8.111:2283 `
  --api-key Mh3ZyWf0RbJ7SnUoQXkT1eP6Cvg8LDAjVslI9Giggle2p `
  --dry-run `
  --sync-albums `
  --include-trashed `
  --include-unmatched `
  --pause-immich-jobs=FALSE `
  "O:\Testimg_import3\*.zip"

```


* * *

#### Immich-CLI (lets you name the album)

I understand if you wanted to take your time importing your files, and only wanted to use officially supported tools. 

Here is an example to import only the files in the current directory, and to give them a specific album name, in this case: `birthday2024`

```bash

MY_IMMICH_API_KEY=Tf2m9WzH8bpYndik7RVeAZr4DH3LwtMluLggk6TXe; \
IMMICH_ALBUM_NAME=birthday2024; \
docker run -it -v "$(pwd)":/import:ro \
  -e IMMICH_INSTANCE_URL=http://172.21.8.111:2283 \
  -e IMMICH_API_KEY=$MY_IMMICH_API_KEY \
  ghcr.io/immich-app/immich-cli:latest \
  upload --dry-run --album-name $IMMICH_ALBUM_NAME \
  -c 5 --recursive .

```


* * *

#### Immich-CLI (Google Takeout)

You can even use it to import your Google Takeout photos, see example below:

```bash

docker run --rm -it \
  --name immich_cli \
  --network br0.8 \
  --ip 172.21.8.112 \
  -v "/mnt/user/Mobile Backups/Testimg_import3/:/import:ro" \
  -e IMMICH_INSTANCE_URL=http://172.21.8.111:2283 \
  -e IMMICH_API_KEY=Kv6e4NpD1qtLsgow3PKmSYm7ZT8JxpLurXxxd2RCf \
  ghcr.io/immich-app/immich-cli:latest \
  upload from-google-photos \
    -dry-run \
    -include-trashed \
    -include-unmatched \
    -create-albums \
    -c 2 \
    /import/takeout-20250614TZ-001.zip \
    /import/takeout-20250614TZ-1-001.zip

```


* * *

## Third step: Immich stack

[Immich-stack](https://github.com/majorfi/immich-stack) is designed to [automatically group similar photos](https://majorfi.github.io/immich-stack/getting-started/quick-start/) into [stacks](https://immich.app/docs/api/create-stack/) within the Immich photo management system. Its primary purpose is to help users organize large photo libraries by stacking related images—such as burst shots, [similar filenames](https://majorfi.github.io/immich-stack/api-reference/environment-variables/?h=criteria#custom-criteria_1), or images taken in quick succession—into logical groups for easier browsing and management



### Duplicates with Immich stack

Stacking your images is basically how you "keep" your duplicates together. Even if they are smaller size, less image resolution, have poor color density, but hey -- gotta keep 'um all.

Immich has a feature to help you inspect every duplicate and decide to trash it, stack it, or just plain keep it. It's pretty good at deciding to trash the older, or smaller in size photo.


* * *

#### Immich-Stack Introduction

You run immich-stack as a command-line tool or via Docker. It connects to your Immich server using an API key and processes your photo library according to the criteria you specify.

The real beauty of immich-stack is it lets you specify how your files have been named, then stack them accordingingly. Let me give you an example:


* * *

### Example Immich-Stack Command

Here is an example of an immich-stack command, please note the `--critera` section, explained below:

```bash

immich-stack \
--criteria '[{"key":"originalFileName","split":{"delimiters":["+", "."],"index":0}}]' \
--parent-filename-promote ",+" \
--dry-run \
--api-key Tu4p1OgS6tUrl3scA4r3m31OIaGVrwrLvrGtl75PCg \
--api-url http://172.21.8.111:2283

```


#### Immich-Stack Command Explained

Sorry, let me explain this a little. Their [wiki](https://majorfi.github.io/immich-stack/) isnt too easy to go by.


- `--criteria:` Specifies how to group photos. In this example, it splits the `originalFileName` on `+` and `.` and uses the first segment, (`+`), as the grouping key. This is useful for stacking images that share a common base filename (e.g., burst shots like `IMG_1234+1.JPG`, `IMG_1234+2.JPG`).

- `--parent-filename-promote:` Controls which photo in a stack is promoted as the parent. The value `",+"`  will give a preference for filenames without a `+` sign.

- `--dry-run:` Performs a simulation without making changes, so you can review what would happen.

- `--api-key:` Your Immich API key for authentication.

- `--api-url:` The URL to your Immich server's API endpoint.


* * *

### Immich-GO Stacking

Immich-Stack is best with defined delimiters and parent promotion. If you're not using it for that, then there's no real reason to use immich-stack.

You're just letting it go find duplicates or similar photos and stack them, you can use Immich-GO.

Stack photos using immich-go is done with the `stack` command, which connects to your Immich server and groups related photos together based on the options for stacking below:



#### Options for Immich-GO Stacking

- `--server` (or `-s`): Your Immich server address (required).

- `--api-key` (or `-k`): Your Immich API key (required).

- `--dry-run`: Simulate actions without making changes.

- `--manage-burst`: Manage burst photos (options: NoStack, Stack, StackKeepRaw, StackKeepJPEG).

- `--manage-raw-jpeg`: Manage RAW+JPEG pairs (options: NoStack, KeepRaw, KeepJPG, StackCoverRaw, StackCoverJPG).

- `--manage-heic-jpeg`: Manage HEIC+JPEG pairs (options: NoStack, KeepHeic, KeepJPG, StackCoverHeic, StackCoverJPG).

- `--manage-epson-fastfoto`: Stack Epson FastFoto scans with the corrected scan as the cover.


* * *

##### Immich-GO Stacking Example: Stack RAW+JPEG pairs with the RAW file as the cover

```bash

MY_IMMICH_API_KEY=Ab3Tg5kPzQ9CwL8WbYdRsH3VvDf7GxF1Zh6JmK9A3t4L; \
immich-go stack --server=http://172.21.8.111:2283 \
  --api-key=$MY_IMMICH_API_KEY \
  --dry-run \
  --manage-raw-jpeg=StackCoverRaw

```


* * *

##### Immich-GO Stacking Example: Stack burst photos**

```bash

MY_IMMICH_API_KEY=Jq5KnX2Bf7WsRp9VtHgYzDdQm8ZtUv0Cv4JsLwP3a1BoK; \
immich-go stack --server=http://172.21.8.111:2283 \
  --api-key=$MY_IMMICH_API_KEY \
  --dry-run \
  --manage-burst=Stack

```


* * *

## Fourth step: Immich compress

Having everyone in the family jump on your Immich server as their primary means of backup (Google Photos alternative). Then you may have a server filling up very fast.

- Grandma has several a 5GB video of her favorite train rides. 

- Uncle uses 50MB jpegs for edits of his best photos.

- Cousin stores all of his photos as RAW/CR2 files (psst - tell them there's a [Lightroom Immich plugin](https://blog.fokuspunk.de/lrc-immich-plugin/)).

Yeah. **Lossy compression may be deemed acceptable.** 

Original files will always be backed up and stored off site. But if you really need compression with no loss in image data, try [immich-upload-optimizer](https://github.com/miguelangel-nubla/immich-upload-optimizer).


* * *

### 1. Compressing Video Files Over a Specific Size

Grandma and her train rides... If you have several people uploading large video files that are tapping your storage space as outliers, compress them.

I have a script that will:

- Compress videos above a certain size.

- Backup the original video.

That should take care of any concerns about people gobbling up space with a few large video files. 

The original video can be stored off site, or on a slower storage medium. It doesnt, really need to be on the Immich server, heck, it doesnt really need it exist at all. Delete it. It's up to you.

You can find the `inplace_mp4_optimizer.sh` script in the [compress2largeVIDEOS](https://github.com/MarcusHoltz/immich-setup/tree/main/compress2largeVIDEOS) folder in my [Immich Setup Repo](https://github.com/MarcusHoltz/immich-setup/).


* * *

### 2. Compressing Image Files Over a Specific Size

Uncle and his darkroom skills... Has certain files that are way larger than the rest of the media that sits on the server, compress them.

I have a script that will:

- Compress images above a certain size.

- Backup the original image.

That should take care of any concerns about people gobbling up space with large images. 

The original image can be stored off site, or on a slower storage medium. It doesnt, really need to be on the Immich server, heck, it doesnt really need it exist at all. Delete it. It's up to you.

You can find the `inplace_jpg_optimizer.sh` script in the [compress2largeIMAGES](https://github.com/MarcusHoltz/immich-setup/tree/main/compress2largeIMAGES) folder in my [Immich Setup Repo](https://github.com/MarcusHoltz/immich-setup/).


* * *

### 3. Compressing CR2 Files down to JPEG

I made a script to import a family member's CR2 library. 

We're going to presume the family member's CR2 library will remain on their prem, maintained by them, but we all want to see their photos in Immich.

So this script assumes you're at a remote location, prepping content to import back to your Immich server - but to do so later with Immich-GO or Immich-CLI.

So, the script assumes you're outputting not to Immich, but to a folder, or external hard drive, or network resource, whatever. You will need somewhere to store these **new** files.

You can find the `cr2jpeg.sh` script in the [batchCR2intoJPEG](https://github.com/MarcusHoltz/immich-setup/tree/main/batchCR2intoJPEG) folder in my [Immich Setup Repo](https://github.com/MarcusHoltz/immich-setup/).


* * *

## 🎉 Congratulations! 🎉

You've officially installed and configured Immich, that's an achievement! 

Now you have a powerful self-hosted solution for managing your photos and media, and you've also taken control of your own environment. 

There’s nothing quite like seeing something you’ve set up from the ground up start working smoothly.

Now, go ahead and enjoy the pics of your labor. 

