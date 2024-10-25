import * as THREE from './libs/three.module.js'; //this works because index.html has three import mapped to the explicit path


class MainThreeJSClass {
    constructor() { }

    async init() {
        this.renderer = new THREE.WebGLRenderer();
        this.renderer.setSize(500,500);
        document.body.appendChild(this.renderer.domElement);
        
        this.scene = new THREE.Scene();
        this.camera = new THREE.OrthographicCamera(0, 1, 1, 0, 0.1, 1000);
        this.camera.position.set(0, 0, 1);

        //basic material
        //const material = new THREE.MeshBasicMaterial({color: 0xff0000});
        
        //shader based material
        const vsh = await fetch('./shaders/vertex-shader.glsl');
        const fsh = await fetch('./shaders/fragment-shader.glsl');
    
        const material = new THREE.ShaderMaterial({
          uniforms: {
          },
          vertexShader: await vsh.text(),
          fragmentShader: await fsh.text()
        });


        const geometry = new THREE.PlaneGeometry(0.1, 0.1);
      
        this.plane = new THREE.Mesh(geometry, material);
        
        this.x = -0.05; 
        this.y = 0.5;
        this.z = 0.5;
        //this.x, this.y. this.z
        this.plane.position.set(this.x, this.y, this.z);

        this.scene.add(this.plane);
        
        this.renderer.setAnimationLoop(this.animate.bind(this));
    }

    animate() {
        this.x += 0.01;
        if (this.x > 1.05)
            this.x = -0.05;
        this.plane.position.set(this.x, this.y, this.z)
        this.renderer.render(this.scene, this.camera);
    }

}


console.log("starting...");
let mainClass = new MainThreeJSClass();
mainClass.init();
