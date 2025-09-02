export const siteConfig = {
  author: 'Team MapleByte for G20 Disaster Risk Reduction Hackathon',
  title: 'Team MapleByte for G20 Disaster Risk Reduction Hackathon',
  subtitle: 'Vitesse theme for Astro, supports Vue and UnoCSS.',
  description: 'A team blog describing the work Canadian Team MapleByte undertook during the G20 Disaster Risk Reduction (DRR) Hackathon running September 2-5 2025.',
  image: {
    src: '/hero.jpg',
    alt: 'Website Main Image',
  },
  email: 'climatechange@deploy.solutions',
  socialLinks: [
    {
      text: 'GitHub',
      href: 'https://github.com/NickKellett/hackathon-g20-drr',
      icon: 'i-simple-icons-github',
      header: 'i-ri-github-line',
    },
  ],
  header: {
    logo: {
      src: '/favicon.png',
      alt: 'Logo Image',
    },
    navLinks: [
      {
        text: 'Home',
        href: '/',
      },
      {
        text: '0_Overall_Results',
        href: '/blog/0',
      },
      {
        text: '1_Settlement_Detection',
        href: '/blog/1',
      },
      {
        text: '2_Settlement_Growth',
        href: '/blog/2',
      },
      {
        text: '3_Flood_Risk',
        href: '/blog/3',
      },
      {
        text: '4_Policy_Outreach',
        href: '/blog/4',
      },
    ],
  },
  page: {
    blogLinks: [
      {
        text: '0_Overall_Results',
        href: '/blog/0',
      },
      {
        text: '1_Settlement_Detection',
        href: '/blog/1',
      },
      {
        text: '2_Settlement_Growth',
        href: '/blog/2',
      },
      {
        text: '3_Flood_Risk',
        href: '/blog/3',
      },
      {
        text: '4_Policy_Outreach',
        href: '/blog/4',
      },
    ],
  },
  footer: {
    navLinks: [
      {
        text: 'View online',
        href: 'https://g20hack-maplebyte.climatechange.ca/',
      },
      {
        text: 'Team MapleByte G20 DRR Hackathon GitHub Repository',
        href: 'https://github.com/NickKellett/hackathon-g20-drr',
      },
      {
        text: 'Astro Theme GitHub Repository',
        href: 'https://github.com/kieranwv/astro-theme-vitesse',
      },
    ],
  },
}

export default siteConfig
