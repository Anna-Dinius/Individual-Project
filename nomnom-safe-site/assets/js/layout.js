document.getElementById('navbar').innerHTML = `
<nav class="navbar navbar-expand-lg">
  <div class="container-fluid">
    <a class="navbar-brand" href="index.html">NomNom Safe</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><a class="nav-link" href="index.html">Home</a></li>
        <li class="nav-item"><a class="nav-link" href="about.html">About</a></li>
        <li class="nav-item"><a class="nav-link" href="docs.html">Documentation</a></li>
      </ul>
    </div>
  </div>
</nav>
`;

document.getElementById('footer').innerHTML = `
<footer>
  &copy; ${new Date().getFullYear()} NomNom Safe. All rights reserved.
</footer>
`;
