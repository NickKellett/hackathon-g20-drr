// @ts-check
import { defineConfig } from 'astro/config';
import markdoc from '@astrojs/markdoc';
import starlight from '@astrojs/starlight';
import starlightUtils from "@lorenzo_lewis/starlight-utils";

// https://astro.build/config
export default defineConfig({
	integrations: [
		markdoc(),
		starlightUtils(),
		starlight({
			title: 'G20 DRR Hackathon Microsite for Policy Makers',
			social: {
				github: 'https://github.com/NickKellett/hackathon-g20-drr',
			},
			components: {
				Head: "/src/components/docs/Head.astro",
				Footer: '/src/components/docs/Footer.astro',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Quickstart', slug: 'guides/flood-government' },
					],
				},
				{
					label: 'Concepts',
					items: [
						{ label: 'Overview', slug: 'model/overview' },						
						{ label: 'community', link: 'model/community' },
						{ label: 'structure', link: 'model/structure' },
						{ label: 'Peril', link: 'model/peril' },
						{ label: 'Hazard', link: 'model/hazard' },
						{ label: 'Hazard Indicator', link: 'model/hazard_indicator' },
						{ label: 'Risk Assessment', link: 'model/risk_assessment' },
						{ label: 'Exposure', link: 'model/exposure' },
						{ label: 'Vulnerability', link: 'model/vulnerability' },
						{ label: 'Impact', link: 'model/impact' },
						{ label: 'Risk Reduction Action', link: 'model/risk_reduction_action' },
						{ label: 'Risk Reduction Question', link: 'model/risk_reduction_question' },
					]
				},	
				{
					label: 'Floods',
					autogenerate: { directory: 'floods' },
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
						{ label: 'G20 DRR Hackathon Microsite for Informal Settlement Community Leaders', link: 'https://g20hack-user-resident.climatechange.ca' },
						//{ label: 'Deploy Solutions Website', link: 'https://www.deploy.solutions' },
					],
				}
				
			],
		}),
	], 
	output: 'static',
	site: 'https://prr-crm-public.climatechange.ca',
});
