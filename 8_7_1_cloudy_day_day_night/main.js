import * as THREE from 'three';

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';


class MainThreeJSClass {
    constructor() { }

    async init() {
        this.renderer = new THREE.WebGLRenderer();
        document.body.appendChild(this.renderer.domElement);
        
        window.addEventListener('resize', () => {
          this.onWindowResize();
        }, false);

        this.scene = new THREE.Scene();
        this.camera = new THREE.OrthographicCamera(0, 1, 1, 0, -1000, 1000);
        this.camera.position.set(0, 0, 1);

        //shader based material
        const vsh = await fetch('./shaders/vertex-shader.glsl');
        const fsh = await fetch('./shaders/fragment-shader.glsl');
    
        this.material = new THREE.ShaderMaterial({
          uniforms: {
            resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight)},
            time: {value: 0.0}
          },
          vertexShader: await vsh.text(),
          fragmentShader: await fsh.text()
        });
        
        const planeGeometry = new THREE.PlaneGeometry(1, 1, 1, 1);
        this.plane = new THREE.Mesh(planeGeometry, this.material);
        this.plane.position.set(0.5, 0.5, 0.0);
        this.scene.add(this.plane);

        this.onWindowResize();

        this.totalTime = 0.0;
        this.totalTimeAtPreviousFrame = null;
        
        this.animate();
    }

    onWindowResize() {
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.material.uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
    }

    animate() {
      // this.x += 0.01;
      // if(this.x >= 1.15) {
      //   this.x = -0.15;
      // }
      // this.plane.position.set(this.x, this.y, this.z);

      requestAnimationFrame((t) => {
        this.keepTrackOfTimeAndUpdateUniform(t);
        
        this.renderer.render(this.scene, this.camera)
        this.animate();

        this.totalTimeAtPreviousFrame = t;
      });
    }

    keepTrackOfTimeAndUpdateUniform(t) {
      if(this.totalTimeAtPreviousFrame === null)
        this.totalTimeAtPreviousFrame = t;

      this.totalTime += (t - this.totalTimeAtPreviousFrame) * 0.001;

      this.material.uniforms.time.value = this.totalTime;
      // this.material.uniforms.time.value = t * 0.001; //not really sure why this isn't used...
      // console.log(this.totalTime, "/", t * 0.001);
      // console.log("dayTime=", this.totalTime%20);
    }

}


console.log("starting...");
let mainClass = new MainThreeJSClass();
mainClass.init();
