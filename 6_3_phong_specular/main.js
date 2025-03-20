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
        // this.camera = new THREE.OrthographicCamera(-1, 1, 1, -1, -1000, 1000);
        this.camera = new THREE.PerspectiveCamera(60, 1/1, 0.1, 1000.0);
        this.camera.position.set(1, 1, 3);

        this.controls = new OrbitControls(this.camera, this.renderer.domElement);
        this.controls.target.set(0, 0, 0);
        this.controls.update();

        const cubeTextureLoader = new THREE.CubeTextureLoader();
        cubeTextureLoader.setPath('./resources/');
        const cubeTexture = cubeTextureLoader.load([
          'Cold_Sunset__Cam_2_Left+X.png',
          'Cold_Sunset__Cam_3_Right-X.png',
          'Cold_Sunset__Cam_4_Up+Y.png',
          'Cold_Sunset__Cam_5_Down-Y.png',
          'Cold_Sunset__Cam_0_Front+Z.png',
          'Cold_Sunset__Cam_1_Back-Z.png'
        ]);
        // console.log(cubeTexture);

        this.scene.background = cubeTexture;

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
        
        const gltfLoader = new GLTFLoader();
        gltfLoader.setPath('./resources/');
        const modelName = 'suzanne.glb';
        // const modelName = 'giant_low_poly_tree.glb';
        // const modelName = 'low_poly_tree_pack.glb';
        // const modelName = 'low_poly_tree.glb';
        gltfLoader.load(modelName, (gltf) => {
          gltf.scene.traverse(c => {
            c.material = this.material;
          });
          this.monkeyModel = gltf.scene;
          this.scene.add(this.monkeyModel);
        });

        

        // const boxGeometry = new THREE.BoxGeometry(1, 1, 1, 1, 1, 1);
        // this.box = new THREE.Mesh(boxGeometry, this.material);
        // this.box.position.set(0.0, 0.0, 0.0);
        // this.scene.add(this.box);

        // const sphereGeometry = new THREE.SphereGeometry(1.25, 50, 50);
        // this.sphere = new THREE.Mesh(sphereGeometry, this.material);
        // this.sphere.position.set(0.0, 0.0, 0.0);
        // this.scene.add(this.sphere);

        // this.onWindowResize();

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
