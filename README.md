# Preface

This is my write-up on how I solved the puzzle at http://hunt.reaktor.com .
I used MacOSX but I assume the same instructions can be applied to other *nix
systems.

## Level 1

Listen to clue.wav.

Then you should be told that the message sequence is ```2 Foxtrot 7 0 6 1 7 4 6 9 6 5 6 Echo 7 4 3 0```.

According to the [International Radiotelephony Spelling Alphabet](https://en.wikipedia.org/wiki/International_Radiotelephony_Spelling_Alphabet),
```Foxtrot``` means ```F``` and ```Echo``` means ```E```.

If we transform the original message, we get ```2 F 7 0 6 1 7 4 6 9 6 5 6 E 7 4 3 0```.
If you look at this string now, it looks like it is encoded in hexadecimal
form.

If you make groups of 2 characters, and convert them to the corresponding
[ASCII](https://en.wikipedia.org/wiki/ASCII) character, you will get:

- 2F = /
- 70 = p
- 61 = a
- 74 = t
- 69 = i
- 65 = e
- 6E = n
- 74 = t
- 30 = 0

This is the path you need to use in the URL (```http://hunt.reaktor.com/patient0```) to get to the next level.

## Level 2

If you put http://hunt.reaktor.com/patient0 into a browser, you will get a copy
of an e-mail exchanged between dunningpharma.com employees.

The conversation in the e-mail offers no valuable clues to proceed to the next
level. They are just there, I guess, to give you some context of what is
happening in this fictitious company :)

The important part here, is to notice that in the e-mail headers there is the
IP address of the SMTP server involved in the delivery of the e-mail.
The IP address is ```46.101.223.113``` and for some reason it appears there is
an HTTP server running there.
Try to connect to it with a browser by accessing ```http://46.101.223.113```.

```
Attemping to connect to mail.dunningpharma.com... - Unable to connect. DNS
record hostname does not match loopback address.
```

This looks like an error. But you get an hint. It is telling you something
about the hostname ```mail.dunningpharma.com``` not matching something, and for
that reason failing the request.
The real thing here is to understand how HTTP requests work, specifically the
importance of the ```Host``` header.
If you are proficient with HTTP you already know this but, when you access some
website say ```www.google.com``` , your browser will send a request like:

```
GET / HTTP/1.1
Host: www.google.com
```

But, if you resolve the DNS name manually and put it in the browser (say 1.2.3.4),
your browser will send a request like:

```
GET / HTTP/1.1
Host: 1.2.3.4
```

In case of google, they will probably serve you the same page content. So
what's the difference you ask? The difference is that it is possible to handle
it differently (say for  security reasons, or for
[Virtual Hosting](https://en.wikipedia.org/wiki/Virtual_hosting)
reasons, etc.), and this happens to be also the case with the HTTP server
running at ```46.101.223.113```.

First time, I tried accessing ```http://mail.dunningpharma.com``` directly,
which would force my browser to send the correct ```Host``` header. But this
didn't work because the browser resolved the DNS hostname
```mail.dunningpharma.com``` to something else than ```46.101.223.113```. Also,
that page appears to be completely unrelated to reaktor hunt challenge.

So the challenge here is, you have to connect to ```46.101.223.113``` but send
the ```Host: mail.dunningpharma.com``` header. I am sure there are browser
extensions for doing this, but I just used ```curl``` utility on my UNIX
machine. However, I will use telnet here for the purpose of this demonstration:

```
$ telnet 46.101.223.113 80
Trying 46.101.223.113...
Connected to 46.101.223.113.
Escape character is '^]'.
GET / HTTP/1.1
Host: mail.dunningpharma.com

HTTP/1.1 303 See Other
Connection: close
Location: /DKELLEY_3_OCT_1982
Date: Fri, 09 Oct 2015 07:30:03 GMT
Content-Length: 28

body unavailable - try head
Connection closed by foreign host.
```

There are two important hints in this output.

The first one is you are being redirected to ```/DKELLEY_3_OCT_1982```.

I could not see a clue in this first hint. For more on this proceed to "Trap 1".

The second one is the hint in ```body unavailable - try head```. This is
actually telling us to use the ```HEAD``` method defined by the HTTP
specification. And we try that:

```
Trying 46.101.223.113...
Connected to 46.101.223.113.
Escape character is '^]'.
HEAD / HTTP/1.1
Host: mail.dunningpharma.com

HTTP/1.1 200 OK
Connection: close
X-Viktor-Tar-Gz: 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
Date: Fri, 09 Oct 2015 07:42:43 GMT

Connection closed by foreign host.
```

Now we are onto something. This ```X-Viktor-Tar-Gz``` is basically a base64 encoded string of some ```tar.gz``` file.
First, we store the base64 string of this header into a base64.txt file, and then decode it into a binary file.
On a UNIX machine you just need to do:

```
base64 --decode -i base64.txt -o base64.tar.gz
```

Then we decompress it, since it's a tar.gz file:

```
tar xvzf base64.tar.gz
```

The output will be a ```viktor``` file that has the clue to the next level.

## Level 3

Now you have a ```viktor``` file.
If you look at the file you will notice it is a
[BMP](https://en.wikipedia.org/wiki/BMP_file_format) file. One quick way to
identify this is because it is a binary file and it starts with the signature
``BM`` as its first two bytes. For more on the image itself proceed to "Trap 2".

For some reason, you will notice that this file may not open on your regular
image viewer. If you look at the file with some hexadecimal editor, you will
notice this file has been tampered with, or more accurately, a message has been
[hidden inside](https://en.wikipedia.org/wiki/Steganography).

You can use hexdump, like follows, to display the file in hexadecimal with an
ASCII representation on the right:

```
$ hexdump -C viktor
... (ommited)
00003b10  00 00 00 00 00 00 00 00  11 11 01 01 11 10 10 10  |................|
00003b20  10 00 00 00 01 00 00 00  00 00 63 48 4a 70 62 6e  |..........cHJpbn|
00003b30  51 67 63 6d 56 6b 64 57  4e 6c 49 48 73 67 4a 47  |QgcmVkdWNlIHsgJG|
00003b40  45 67 4b 69 41 6b 59 69  42 39 49 47 31 68 63 43  |EgKiAkYiB9IG1hcC|
00003b50  42 37 49 48 4e 31 59 6e  4e 30 63 69 67 6e 4a 79  |B7IHN1YnN0cignJy|
00003b60  41 72 49 48 4e 78 63 6e  51 6f 4a 46 38 67 4b 69  |ArIHNxcnQoJF8gKi|
00003b70  41 7a 4b 53 77 67 4d 79  77 67 4d 53 6b 67 66 53  |AzKSwgMywgMSkgfS|
00003b80  42 6e 5a 58 51 6f 4a 32  68 30 64 48 41 36 4c 79  |BnZXQoJ2h0dHA6Ly|
00003b90  39 6f 64 57 35 30 4c 6e  4a 6c 59 57 74 30 62 33  |9odW50LnJlYWt0b3|
00003ba0  49 75 59 32 39 74 4c 32  31 68 5a 32 6c 6a 62 6e  |IuY29tL21hZ2ljbn|
00003bb0  56 74 59 6d 56 79 4a 79  6b 67 50 58 34 67 4c 31  |VtYmVyJykgPX4gL1|
00003bc0  73 79 4e 44 64 64 4c 32  31 6e                    |syNDddL21n|
00003bca
```

As you can see, the file ends with a string that clearly stands out from the
rest of the file. This string is as follows:

```
cHJpbnQgcmVkdWNlIHsgJGEgKiAkYiB9IG1hcCB7IHN1YnN0cignJyArIHNxcnQoJF8gKiAzKSwgMywgMSkgfSBnZXQoJ2h0dHA6Ly9odW50LnJlYWt0b3IuY29tL21hZ2ljbnVtYmVyJykgPX4gL1syNDddL21n
```

This string also happens to be encoded in base64.  We store this string in a
file called ```viktor_secret.txt``` and then decode it. On a UNIX machine you
just need to do:

```
base64 --decode -i viktor_secret.txt -o viktor_secret_revealed.txt
```

## Level 4

The file ```viktor_secret_revealed.txt``` is actually a Perl language script.

```perl
print reduce { $a * $b } map { substr('' + sqrt($_ * 3), 3, 1) } get('http://hunt.reaktor.com/magicnumber') =~ /[247]/mg
```

Let us copy this file to ```viktor.pl``` and try to run it for now:

```
$ perl viktor.pl
syntax error at viktor.pl line 1, near "} map"
Execution of viktor.pl aborted due to compilation errors.
```

As you can see, the file is just broken (incomplete, to be more accurate) so it
doesn't execute properly. We get an error related to ```} map```.  This is
because your Perl interpreter is not recognizing the ```reduce``` function.
You need to first include support for this function by adding

```perl
use List::Util 'reduce';
```

to the top of the file, right before the ```print```.

Now if you execute it again, the error will be different but we would have made
some progress.

```
$ perl viktor.pl
Undefined subroutine &main::get called at viktor.pl line 2.
```

Now the error is about ```get```. This is because in the script we have, the
script is trying to access some URL, by calling a function called ```get```,
for fetching its contents. Like ```reduce```, you need to tell Perl to use it
  by adding

```perl
use LWP::Simple;
```

before the ```print```.

Now if you execute it again

```
$ perl viktor.pl
10871635968
```

You will get a number. You will notice that, if you execute the script again
and again, every few seconds, this number will change. This is not because you
execute it: the number will still change even if you don't execute it.
I assume, this is because, somewhere in the hunt.reaktor.com server, there is
some form of time-based token authentication mechanism. Some examples of this
are [TOTP](https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm),
[RSA SecurID](https://en.wikipedia.org/wiki/RSA_SecurID), or even the more
familiar
[Two-Factor Authentication](https://en.wikipedia.org/wiki/Two-factor_authentication)
commonly provided by big companies and services for improving authentication.

The idea here is to execute the Perl script, and immediately insert that code
as the ```Passcode``` into http://hunt.reaktor.com . Don't forget to type in an
e-mail address too.

Beware, since this is a time-based authentication mechanism, if you are not
fast enough to execute the perl script, and submit the code to reaktor, the
code will become invalid and your submition will fail.

If your submission succeeds, you will be taken to ```http://hunt.reaktor.com/mutations``` .

## Level 5

You must be careful because, if you just put
```http://hunt.reaktor.com/mutations```, in your browser, it is likely that
your HTML will display the contents of the e-mail incorrectly, specifically the
part that begins with ```begin 640 label```.

You need to use the "View Source" menu of your browser, or download this URL
using ```curl```, ```wget``` or whatever tool you see fit. Let us use curl now.

```
$ curl -O http://hunt.reaktor.com/mutations
```

When you execute it, you will have downloaded a file called ```mutations```.
When you look at it, you will see it's another e-mail between dunningpharma.com
employees.
The interesting part of the e-mail is the attachment of this e-mail message.
The way the file is attached to the e-mail, follows the format
```begin ... end```.
This form of encoding a binary message within a text message is called
[uuencoding](https://en.wikipedia.org/wiki/Uuencoding).

```
begin 640 label
(here are the contents, ommited)
end
```

```640``` defines the file's permissions (in UNIX chmod format), ```label``` is the filename.
The contents after that and before ```end``` mark the contents of the file in uuencoding.
There is a UNIX tool which you can throw the whole ```mutations``` e-mail at,
and it will export you all attachment files inside, as follows:

```
$ uudecode mutations
```

Now you will have a file called ```label``` on your disk.

## Level 6

In the previous level, you got a ```label``` file.
If you try to throw it at an hexadecimal editor, you will see the signature
```PNG``` in the beggining of the file:

```
$ hexdump -C label.png
00000000  89 50 4e 47 0d 0a 1a 0a  00 00 00 0d 49 48 44 52  |.PNG........IHDR|
00000010  00 00 00 e8 00 00 00 32  01 03 00 00 00 6c c2 05  |.......2.....l..|
00000020  72 00 00 00 06 50 4c 54  45 ff ff ff 00 00 00 55  |r....PLTE......U|
00000030  c2 d3 7e 00 00 00 09 70  48 59 73 00 00 0e c4 00  |..~....pHYs.....|
00000040  00 0e c4 01 95 2b 0e 1b  00 00 00 34 49 44 41 54  |.....+.....4IDAT|
00000050  38 8d 63 60 18 05 24 00  b6 09 73 27 6f d6 cb f3  |8.c`..$...s'o...|
00000060  9b 79 7b bb 5a cc b9 e8  49 c5 7e b9 27 27 2f 39  |.y{.Z...I.~.''/9|
00000070  66 75 60 54 76 54 76 54  76 10 c8 8e 02 38 00 00  |fu`TvTvTv....8..|
00000080  91 27 8a 77 c5 90 04 16  00 00 00 00 49 45 4e 44  |.'.w........IEND|
00000090  ae 42 60 82                                       |.B`.|
00000094
```

This is because, as the signature states, this file is in fact a
[PNG](https://en.wikipedia.org/wiki/Portable_Network_Graphics) file.

For simplicity, let us copy this file to ```label.png``` so that we can open it
with our favorite image viewer.

When you open it, you will notice it is an image with a barcode.
It seems we have to read the code inside.
I used [zbar](http://zbar.sourceforge.net/index.html) but you could use some
[online barcode reader](https://www.google.com/search?q=online+barcode+reader) to
upload ```label.png``` and read the code for you.

```
$ zbarimg label.png
CODE-128:00358753251154
scanned 1 barcode symbols from 1 images in 0 seconds
```

So the code we get is ```00358753251154```.

## Level 7

The only thing about this level is to understand what ```00358753251154``` refers to.
At first I thought it could be a phone number, because of the ```00``` prefix,
I put on Skype and noticed it was a phone number to Finland. I never saw a
puzzle that got "this real" so I ignored it.
Then I thought it could be an IP address or mathematical integer sequence, and
even tried doing something with it but to no avail.
Finally, I gave up and called this number on Skype.
The moment I listen to the other side of the phone, a recording similar to the first level,
I knew this had to be the right path :)
I saved the recording of the call in a file called ```00358753251154.m4a```, so
that you can listen it too.

## Level 8

There is nothing to this level too.
You just have to type in your e-mail, and the passcode as the number you listen
at the end of the message:

```
598100773291
```

Done :)

# Traps

There were a few traps in the game. I am not sure whether they were
intentionally left as traps, or if I was not smart enough to solve them.

## Trap 1

In Level 2, you are redirected to ```DKELLEY_3_OCT_1982```.
Let us get the contents of that file first:

```
$ telnet 46.101.223.113 80
Trying 46.101.223.113...
Connected to 46.101.223.113.
Escape character is '^]'.
GET /DKELLEY_3_OCT_1982 HTTP/1.1
Host: mail.dunningpharma.com

HTTP/1.1 200 OK
Connection: close
Date: Fri, 09 Oct 2015 07:38:52 GMT
Transfer-Encoding: chunked

2d
<!DOCTYPE html><html><head></head><body><pre>
730
FROM: dkelley@dunningpharma.com
TO: mkarlsso@dunningpharma.com, jsanders@dunningpharma.com
SUBJECT: Re: Clinical trials
DATE: 8 Oct 1982

Jeremy, Mikael,

just got green light from management. We're good to go for clinical trials. I
know you're both probably getting sick of me droning on about this, but
management told me to remind you once more of the strict confidentiality of
your research. We've had a couple of critical leaks in the last few years, and
we can't afford yet another case of Sutherland getting their vaccine out on
the market before us.

I know this is highly unorthodox, but the management wants you to play things
extra careful. They've selected a group of test subjects from inside the
company. These people have all signed waivers and will receive a commensurate
compensation of their efforts.

I have full confidence in you guys. Let's make history.

Daniel Kelley
Director, Advanced Research Unit
Dunning Pharma, Inc.

> On 2 Oct 1982 dkelley@dunningpharma.com wrote:
> 
> This is great news! I have a management board meeting on Thursday. They're 
> anxious to hear of any progress. Boy will they be surprised by your results.
> John will propose continuing with clinical trials immediately - I don't 
> expect there to be any resistance after these tests.
> 
> Daniel Kelley
> Director, Advanced Research Unit
> Dunning Pharma, Inc.
> 
> > On 2 Oct 1982 mkarlsso@dunningpharma.com wrote:
> > 
> > Gentlemen,
> > 
> > triple-blind study results are now in. We now have confirmation of 
> > our modified smallpox vaccine being extremely effective against the HI
> > virus. Results show effective reduction in both CCR5-tropic and
> > CXCR4-tropic HIV-1 replication.
> > 
> > I think we're ready for clinical trials.
> > 
> > Jeremy Sanders, PhD
> > Lead Research Scientist, Drug Discovery
> > Dunning Pharma, Inc.
6
</pre>
18b
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-1103427-24', 'auto');
ga('send', 'pageview');
</script>

e
</body></html>
0

Connection closed by foreign host.
```

The only strange thing I found, was the fact that there are some characters at
the beginning of some lines that appear to be some code in hexadecimal (2d,
730, 6, 18b, e, 0).

What is this?

I really have no idea :)

## Trap 2

In Level 3, you extract a tampered BMP file called ```viktor``` from a tar.gz archive.
Using imagemagick, I converted this file to PNG and then back to BMP to remove
the tampered parts and to be able to open it using my favorite image viewer.

When I looked at the picture, I saw 4 lines with 5-character-group blocks, with
the exception of the last block of the last line which has only 4 characters.

The message reads as follows:

```
KRCLI PTSXO PIETI IFROP
DOEAX XBIOS MBTNM TRESR
MXXRH SBVAY OESOE EUPEX
AUTCD CCLX
```

This immediately striked me as a cryptography problem, because it is common to
write a ciphered message as fixed-size groups of characters.

At first, I tried simple subsitution ciphers, like replacing all K's with some
other alphabet letter, etc., but failed to get any result.

Then I tried transposition ciphers, and I got a positive result when using the
[Rail Fence Cipher](https://en.wikipedia.org/wiki/Rail_fence_cipher) with 5 rails.

You can try it too at the
[Crypto Corner](http://crypto.interactive-maths.com/rail-fence-cipher.html) website.

The decoded message is kind of ambiguous to me, but it looks like a positive result:

```
KOBRAHIPRIOSUBSECTMVTABILITYCONFIRMEDSTOPPROCEEDTOSECURESAMPLEXXXXXXX
```

The remainder ```XXXXX``` is what you call "null" characters, which are just
used to fill the blanks but have no meaning whatsoever.

Some keywords that got my attention:

```
KOBRA: What? Snake?
HI: There was a mention to this in the e-mails!
PRIO: What? Short for Priority?
SUBSECTMVT: What? No idea what this is!
ABILITY
CONFIRMED
STOP
PROCEED
TO
SECURE
SAMPLE
```

I assume this was a trap, because I could not see how the information in this
message could be used to get further information.
