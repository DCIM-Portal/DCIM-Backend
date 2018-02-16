<template>
  <div id="app">
    <p>{{ message }}</p>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  }
}
</script>

<style scoped>
#app {
  position: fixed;
  top: 60px;
}

p {
  font-size: 2em;
  text-align: center;
}
</style>
