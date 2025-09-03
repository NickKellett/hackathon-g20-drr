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
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/withastro/starlight' }],
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Example Guide', slug: 'guides/example' },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
				{
					label: 'Settlements',
					autogenerate: { directory: 'settlements' },
				},
				{
					label: 'Risks',
					autogenerate: { directory: 'risks' },
				},
			],
		}),
	],
});
