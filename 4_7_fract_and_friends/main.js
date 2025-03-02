import * as THREE from './libs/three.module.js';


class MainThreeJSClass {
    constructor() { }

    async init() {
        this.renderer = new THREE.WebGLRenderer();
        //this.renderer.setSize(500,500); //static size of the renderer, commented this & using window size
        document.body.appendChild(this.renderer.domElement);
        
        window.addEventListener('resize', () => {
          this.onWindowResize();
        }, false);

        this.scene = new THREE.Scene();
        this.camera = new THREE.OrthographicCamera(0, 1, 1, 0, 0.1, 1000);
        this.camera.position.set(0, 0, 1);

        //shader based material
        const vsh = await fetch('./shaders/vertex-shader.glsl');
        const fsh = await fetch('./shaders/fragment-shader.glsl');
    
        this.material = new THREE.ShaderMaterial({
          uniforms: {
            resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight)}
          },
          vertexShader: await vsh.text(),
          fragmentShader: await fsh.text()
        });


        const geometry = new THREE.PlaneGeometry(1.0, 1.0);
      
        this.plane = new THREE.Mesh(geometry, this.material);
        
        //console.log(geometry);

        this.x = 0.5; 
        this.y = 0.5;
        //this.z = 0;
        //this.x, this.y. this.z
        this.plane.position.set(this.x, this.y, this.z);

        this.scene.add(this.plane);

        this.onWindowResize();

        this.animate();
    }

    onWindowResize() {
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.material.uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
    }

    animate() {
      requestAnimationFrame(() => {
        this.renderer.render(this.scene, this.camera)
        this.animate();
      });
    }

}


console.log("starting...");
let mainClass = new MainThreeJSClass();
mainClass.init();
