// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'Community Leaders',
			defaultLocale: 'en',
			locales: {
				// English docs in `src/content/docs/en/`
				en: {
					label: 'English',
				},
				// Zulu docs in `src/content/docs/zu/`
				'zu': {
					label: 'isiZulu',
					lang: 'zu',
				},
			},
			customCss: [
				'/src/styles/global.css',
				// add other custom CSS files here if needed
			],
			components: {
				MarkdownContent: '/src/components/MarkdownContent.astro',
				Footer: '/src/components/Footer.astro',
			},
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/withastro/starlight' }],
			sidebar: [
				{
					label: 'Settlements',
					autogenerate: { directory: 'settlements' },
				},
				{
					label: 'Floods',
					autogenerate: { directory: 'floods' },
				},
				{
					label: 'Flood Adaptation & Resilience Guide',
					autogenerate: { directory: 'guides' }
				},
				{
					label: 'About',
					items: [				
						{ label: 'About', slug: 'about/about' },		
					]
				},	
				{
					label: "Related Websites",
					items: [
						{ label: 'Team MapleByte G20 DRR Hackathon Blog', link: 'https://g20hack-maplebyte.climatechange.ca' },
						{ label: 'Team MapleByte GitHub Repo', link: 'https://github.com/NickKellett/hackathon-g20-drr' },
						{ label: 'G20 DRR Hackathon Microsite for Policy Makers', link: 'https://g20hack-user-policy.climatechange.ca' },
						//{ label: 'Deploy Solutions Website', link: 'https://www.deploy.solutions' },
					],
				}
			],
		}),
	],
});
