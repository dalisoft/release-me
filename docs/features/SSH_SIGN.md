---
sidebar_position: 2
---

# SSH Sign

This project allows you use SSH Sign for your Git tags without headaches and with keeping same performance

There a guide how to add SSH Sign for your Git tags on your release workflow

## Step-by-step guide

:::warning

First follow these guides and then come here

- [Checking for existing SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)
- [Generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [Add a SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

:::

### Get your SSH public key

This guide ensures you already followed guides above

```bash title="Bash Terminal"
cat ~/.ssh/path_to_your_pubkey.pub
```

```bash title="Result"
ssh-ed25519 AAAAC__SENSITIVE_PART mail@domain.com
```

then copy all of it's content without marlforming content

### Export your SSH key

```bash title="Bash Terminal"
cat ~/.ssh/path_to_your_privatekey | base64
```

then copy or your result from your **Terminal** app or export to file with command below

```bash title="Bash Terminal"
cat ~/.ssh/path_to_your_privatekey | base64 | base64 > ssh-base64
```

then copy content of `ssh-base64` file

### Save your SSH key

:::tip

See [`SSH Environment variables`](../plugins/GIT.md#ssh-git-variables)

:::

Save your [SSH key](#export-your-ssh-key) as `SSH_PRIVATE_KEY` variable as **SECRET** not **VARIABLE**

### Save your SSH public key

:::tip

See [`SSH Environment variables`](../plugins/GIT.md#ssh-git-variables)

:::

Save your [SSH public key](#get-your-ssh-public-key) as `SSH_PUBLIC_KEY` variable as **SECRET** not **VARIABLE**

### Set your SSH Passphrase

:::tip

If your [SSH key](#export-your-ssh-key) is encrypted by passphrase, you should set passphrase too

:::

Save your [SSH key](#export-your-ssh-key) passphrase as `SSH_KEY_PASSPHRASE` variable as **SECRET** not **VARIABLE**

### That's all

Trigger release and see **signed Git tags** for your release
