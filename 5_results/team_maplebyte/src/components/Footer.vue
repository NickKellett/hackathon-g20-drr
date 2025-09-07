<script lang="ts" setup>
import siteConfig from '@/site-config'
import { getLinkTarget } from '@/utils/link'
</script>

<template>
  <footer class="w-full mt-18 pt-6 pb-8 max-w-3xl text-sm flex flex-col gap-4 border-main border-t !border-op-50 text-dark dark:text-white">
    <div v-if="siteConfig.footer.navLinks && siteConfig.footer.navLinks.length > 0" class="flex flex-wrap gap-4">
      <template v-for="(link, index) in siteConfig.footer.navLinks" :key="link.text">
        <a
          :aria-label="`${link.text}`" :target="getLinkTarget(link.href)" class="nav-link flex items-center"
          :href="link.href"
        >
          {{ link.text }}
        </a>
        <span v-if="index < siteConfig.footer.navLinks.length - 1" op-70> / </span>
      </template>
    </div>
    <div flex>
      <a nav-link href="https://creativecommons.org/licenses/by-sa/4.0/" target="_blank">CC BY-SA 4.0</a>
      <span op-70>&nbsp;&nbsp;&copy;&nbsp;&nbsp;{{ new Date().getFullYear() }}&nbsp;&nbsp;{{ siteConfig.author
      }}.</span>
    </div>
    <div flex>
      Disclaimer: This website is provided for informational purposes only. The information stated herein has, to the best of our knowledge, been collected and verified as much as possible on a best effort basis, within the time constraints of a multi-day hackathon. Team MapleByte and its contributors are volunteers and cannot make any guarantees of any kind, as to the completeness, accuracy, suitability, or reliability of any data, maps, content or links provided in this website or the GitHub repository or micro-sites it references. This information has been prepared for general guidance on matters of interest only and as a reflection of our hackathon activities and does not constitute professional advice. You should not act upon the information without obtaining specific professional advice. No representation or warranty (express or implied) is given as to the accuracy or completeness of the information contained or linked to from here, and we do not accept or assume any liability, responsibility, or duty of care for any consequences to you or anyone else acting, or refraining to act, in reliance on the information contained herein or for any decision based upon it.
    </div>
  </footer>
</template>
