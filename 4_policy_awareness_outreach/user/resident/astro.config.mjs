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
			components: {
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
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Flood Guide', slug: 'guides/flood-community' },
					],
				},
			],
		}),
	],
});
