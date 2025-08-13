class Main {
    hello = "hello";
    world = "world";
    num = 42;

    public main() {
        console.log(`${this.hello} ${this.world} ${this.num}!`);
    }
}

const main = new Main();

main.main();
