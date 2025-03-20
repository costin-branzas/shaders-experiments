import * as THREE from 'three';

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';


class MainThreeJSClass {
    constructor() { }

    async init() {
        this.renderer = new THREE.WebGLRenderer();
        this.renderer.setSize(500,500); //static size of the renderer, commented this & using window size
        document.body.appendChild(this.renderer.domElement);
        
        // window.addEventListener('resize', () => {
        //   this.onWindowResize();
        // }, false);

        this.scene = new THREE.Scene();
        this.camera = new THREE.OrthographicCamera(-1, 1, 1, -1, -1000, 1000);
        this.camera.position.set(0, 0, 1);

        this.controls = new OrbitControls(this.camera, this.renderer.domElement);
        this.controls.target.set(0, 0, 0);
        this.controls.update();

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
        
        const loader = new GLTFLoader();
        loader.setPath('./resources/');
        const modelName = 'suzanne.glb';
        // const modelName = 'giant_low_poly_tree.glb';
        //const modelName = 'low_poly_tree_pack.glb';
        // const modelName = 'low_poly_tree.glb';
        loader.load(modelName, (gltf) => {
          gltf.scene.traverse(c => {
            c.material = this.material;
          });
          const model = gltf.scene;
          // model.material = this.material;
          this.scene.add(model);
          console.log(gltf);
        });

        //this.onWindowResize();

        this.animate();
    }

    onWindowResize() {
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.material.uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
    }

    animate() {
      // this.x += 0.01;
      // if(this.x >= 1.15) {
      //   this.x = -0.15;
      // }
      // this.plane.position.set(this.x, this.y, this.z);

      requestAnimationFrame(() => {
        this.renderer.render(this.scene, this.camera)
        this.animate();
      });
    }

}


console.log("starting...");
let mainClass = new MainThreeJSClass();
mainClass.init();
