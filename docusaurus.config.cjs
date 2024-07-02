// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

const { themes: prismThemes } = require('prism-react-renderer');
const pkg = require('./package.json');

const title = pkg.name.slice(0, -3);

/** @type {import('@docusaurus/types').Config} */
const config = {
  webpack: {
    jsLoader: (isServer) => ({
      loader: require.resolve('swc-loader'),
      options: {
        jsc: {
          parser: {
            syntax: 'ecmascript',
            jsx: true
          },
          target: 'es2020',
          transform: {
            react: {
              runtime: 'automatic'
            }
          }
        },
        module: {
          type: isServer ? 'commonjs' : 'es6'
        }
      }
    })
  },

  title,
  tagline: pkg.description,
  favicon: 'img/favicon-128.png',

  // Set the production url of your site here
  url: pkg.homepage.slice(0, -(title.length + 1)),
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
          editUrl: 'https://github.com/dalisoft/release-me/tree/master/docs/'
        },
        blog: {
          showLastUpdateAuthor: false,
          showLastUpdateTime: false,
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/dalisoft/release-me/tree/master/blog/'
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
      algolia: {
        appId: 'C187DF596C',
        apiKey: '5374d9481460cef25794eff70de04ca4',
        indexName: 'release_me',
        contextualSearch: true,
        insights: false
      },
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
          { to: '/ROADMAP', label: 'Roadmap', position: 'left' },
          {
            position: 'right',
            href: `https://github.com/dalisoft/release-me/releases/tag/v${pkg.version}`,
            label: `v${pkg.version}`
          },
          {
            href: pkg.repository.url.split('+')[1],
            position: 'right',
            className: 'github-link image-link header-image-link',
            'aria-label': 'GitHub repository'
          }
        ]
      },
      footer: {
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
                to: '/ROADMAP'
              }
            ]
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Stack Overflow',
                href: 'https://stackoverflow.com/questions/tagged/release-me',
                className: 'image-link stack-overflow-link social-link-icon'
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
                href: 'https://github.com/dalisoft/release-me',
                className: 'image-link github-link social-link-icon'
              },
              {
                label: 'Report issue',
                href: 'https://github.com/dalisoft/release-me/issues',
                className: 'image-link bug-report-link social-link-icon'
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
