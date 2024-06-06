// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

const { themes: prismThemes } = require('prism-react-renderer');
const pkg = require('./package.json');

const title = pkg.name.slice(4);

/** @type {import('@docusaurus/types').Config} */
const config = {
  title,
  tagline: pkg.description,
  favicon: 'img/favicon-128.png',

  // Set the production url of your site here
  url: 'https://dalisoft.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/release-me',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'dalisoft', // Usually your GitHub org/user name.
  projectName: title, // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    format: 'md'
  },

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en']
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/'
        },
        blog: {
          showLastUpdateAuthor: false,
          showLastUpdateTime: false,
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/'
        },
        theme: {
          customCss: './src/css/custom.css'
        }
      })
    ]
  ],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      metadata: [
        {
          name: 'keywords',
          content: pkg.keywords.join(', ')
        },
        {
          name: 'description',
          content: pkg.description
        },
        {
          name: 'og:site_name',
          content: title
        },
        {
          name: 'og:description',
          content: pkg.description
        },
        {
          name: 'og:url',
          content: pkg.homepage
        }
      ],
      // Replace with your project's social card
      image: 'img/release-me.png',
      navbar: {
        title,
        logo: {
          alt: 'release-me. Logo by https://uxwing.com',
          src: 'img/logo.svg'
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Documentation'
          },
          { to: '/blog', label: 'Blog', position: 'left' },
          { to: '/roadmap', label: 'Roadmap', position: 'left' },
          {
            href: 'https://github.com/dalisoft/release-me',
            label: 'GitHub',
            position: 'right'
          }
        ]
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Documentation',
                to: '/docs/GET_STARTED'
              },
              {
                label: 'Roadmap',
                to: '/roadmap'
              }
            ]
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Stack Overflow',
                href: 'https://stackoverflow.com/questions/tagged/release-me'
              }
            ]
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog'
              },
              {
                label: 'GitHub',
                href: 'https://github.com/dalisoft/release-me'
              }
            ]
          }
        ],
        copyright: `Copyright © 2024 dalisoft`
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash']
      }
    })
};

module.exports = config;
