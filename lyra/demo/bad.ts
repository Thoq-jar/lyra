class Main_Bad {
    hello_var = "hello";
    world_var = "world";
    num_num = 42

    public main() {
        console.log(`${this.hello_var} ${this.world_var} ${this.num_num}!`);
    }
}

var Main_Bad_Var = new Main()

Main_Bad_Var.main();
