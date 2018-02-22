<template>
  <div id="app">
    <navbar></navbar>
    <vue-menu></vue-menu>
    <p>{{ message }}</p>
  </div>
</template>

<script lang="coffee">
  import Navbar from 'rails_dcim_portal/navbar'
  import Menu from 'rails_dcim_portal/menu'

  component =
    components:
      'navbar': Navbar
      'vue-menu': Menu
    data: ->
      message: 'Hello Vue!'

  `export default component`
</script>

<!--
<script>
  import Navbar from 'rails_dcim_portal/navbar'

  export default {
      components: {
          Navbar
      },
      data() {
          return {
              message: "Hello Vue!"
          }
      }
  }
</script>
-->

<style lang="scss" scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
