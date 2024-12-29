// https://threejs.org/manual/#en/shadertoy

function main() {
    if (!WEBGL.isWebGL2Available()) {
        document.body.appendChild(WEBGL.getWebGL2ErrorMessage());
      }
    
    const canvas = document.getElementById('webglcanvas');
    const renderer = new THREE.WebGLRenderer({antialias: true, canvas});
    renderer.autoClearColor = false;
 

      const camera = new THREE.OrthographicCamera(
      -2, // left
       2, // right
       2, // top
      -2, // bottom
      -2, // near,
       2, // far
    );

    const scene = new THREE.Scene();

    const shaderFiles = [
        'glsl/vertexShader.vs.glsl',
        'glsl/fragmentShader.fs.glsl',
    ];

    const material = new THREE.ShaderMaterial({
        uniforms: {
            time: { value: 0 },
            resolution:  { value: new THREE.Vector3() },
          }
    });

    new THREE.SourceLoader().load(shaderFiles, function (shaders) {
        material.vertexShader = shaders['glsl/vertexShader.vs.glsl'];
        material.fragmentShader = shaders['glsl/fragmentShader.fs.glsl'];
      
    })

    const plane = new THREE.PlaneGeometry(4, 4);
    scene.add(new THREE.Mesh(plane, material));

   
    function resizeRendererToDisplaySize(renderer) {
      const canvas = renderer.domElement;
      const width = window.innerWidth;
      const height = window.innerHeight;
  
      const needResize = canvas.width !== width || canvas.height !== height;
      if (needResize) {
        renderer.setSize(width, height, false);
      }
      return needResize;
    }

    let clock = new THREE.Clock(); // Optional, to reset the delta

   
    function render(t) {
        t = clock.getDelta();;  // convert to seconds
       
        resizeRendererToDisplaySize(renderer);
       
        const canvas = renderer.domElement;
        material.uniforms.resolution.value.set(canvas.width, canvas.height, 1);
        material.uniforms.time.value += t;
        material.needsUpdate = true;
        renderer.render(scene, camera);
       
        requestAnimationFrame(render);
      }
   
    requestAnimationFrame(render);
  }
   
  main();