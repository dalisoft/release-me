---
sidebar_position: 1
---

# GPG Sign

This project allows you use GPG Sign for your Git tags without headaches and with keeping same performance

There a guide how to add GPG Sign for your Git tags on your release workflow

## Step-by-step guide

:::warning

First follow these guides and then come here

- [Checking for existing GPG keys](https://docs.github.com/en/authentication/managing-commit-signature-verification/checking-for-existing-gpg-keys)
- [Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
- [Add a GPG key to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

:::

### Get your GPG key ID

This guide ensures you already followed guides above

```bash title="Bash Terminal"
gpg --list-secret-keys
```

```bash title="Result"
[keyboxd]
---------
sec   ed25519 YYYY-MM-DD [SC] [expires: YYYY-MM-DD]
      2B47FD15064C6CCCC90CA251E833E64EF42E8DEA
uid           [ultimate] FirstName LastName <mail@domain.com>
ssb   cv25519 YYYY-MM-DD [E] [expires: YYYY-MM-DD]

sec   ed25519 YYYY-MM-DD [SC]
      ABA8161A192052B2C8C2D68A82406676A919222E
uid           [ unknown] FirstName LastName (Software Engineer) <mail@domain.com>
```

then you can copy any of `Key ID` but i'll choose `ABA8161A192052B2C8C2D68A82406676A919222E` so later all of steps follows this `Key ID`

### Export your GPG key

```bash title="Bash Terminal"
gpg --export-secret-keys ABA8161A192052B2C8C2D68A82406676A919222E | base64
```

then copy or your result from your **Terminal** app or export to file with command below

```bash title="Bash Terminal"
gpg --export-secret-keys ABA8161A192052B2C8C2D68A82406676A919222E | base64 > gpg-base64
```

then copy content of `gpg-base64` file

### Save your GPG key

:::tip

See [`GPG Environment variables`](../plugins/GIT.md#gpg-git-variables)

:::

Save your [GPG key](#export-your-gpg-key) as `GPG_KEY` variable as **SECRET** not **VARIABLE**

### Save your GPG key ID

:::tip

See [`GPG Environment variables`](../plugins/GIT.md#gpg-git-variables)

:::

Save your [GPG key ID](#get-your-gpg-key-id) (example `ABA8161A192052B2C8C2D68A82406676A919222E`) as `GPG_KEY_ID` variable as **SECRET** or **VARIABLE** depending on how much your GPG Key ID are should be secure

### Set your GPG Passphrase

:::tip

If your [GPG key](#export-your-gpg-key) is encrypted by passphrase, you should set passphrase too

:::

Save your GPG passphrase as `GPG_PASSPHRASE` variable as **SECRET** not **VARIABLE**

### That's all

Trigger release and see **signed Git tags** for your release
