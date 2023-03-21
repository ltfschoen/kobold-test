# Kobold Test

Testing the capabilities of Kobold library whilst learning Rust.

### Initial Setup Log

* Added example rust-toolchain.toml
* Install Rust https://doc.rust-lang.org/cargo/getting-started/installation.html
* Update Rust and Cargo
    ```bash
    rustup update
    cargo update
    ```
* Switch to latest "stable" Rustup
    ```bash
    rustup override set stable-x86_64-unknown-linux-gnu
    ```
* Install Kobold dependencies https://github.com/maciejhirsz/kobold#more-examples
    ```bash
    rustup target add wasm32-unknown-unknown
    ```
* Switch to default [Rustup Profile](https://rust-lang.github.io/rustup/concepts/profiles.html)
    ```bash
    rustup set profile default
    ```
* Check Rustup Configuration
    ```bash
    rustup toolchain list
    rustup show
    ```
* Add additional components
    ```bash
    rustup component add rustc cargo rustfmt rust-std rust-docs clippy miri rust-src llvm-tools-preview
    ```
* Created project
```bash
cargo new kobold-test --bin
cargo add kobold
touch index.html
```
* Paste the following in index.html
```bash
<html>
  <head>
    <meta charset="utf-8" />
    <title>Kobold Hello World example</title>
  </head>
  <body></body>
</html>
```

* Paste the following in ./src/main.rs
```bash
use kobold::prelude::{component, html, Html};

#[component]
fn Hello(name: &str) -> impl Html + '_ {
    html! {
        <h1>"Hello "{ name }"!"</h1>
    }
}

fn main() {
    kobold::start(html! {
        <Hello name="Kobold" />
    });
}
```
* Install dependencies
```bash
cargo install --path .
```
* Install [Trunk](https://trunkrs.dev/#getting-started)
* Create Trunk.toml & Paste:
```bash
[tools]
wasm_bindgen = "0.2.84"
```
* Build, watch and serve the Rust WASM web application and all its assets. Automatically opens in web browser.
```bash
trunk --config ./trunk/Trunk.toml serve --address=127.0.0.1 --open
```
    * Note: Replace with public IP address to access externally if firewall permissions allow

### Docker

* Runs server inside Docker container. Build artifacts dist/ and target/ are generated inside the Docker container with hot reloading.
* Install and run [Docker](https://www.docker.com/)
* Run in Docker container
```bash
./scripts/docker-dev.sh
```
* View website http://<PUBLIC_IP_ADDRESS>:8080

* Kill Docker container
```
docker stop kobold-test && docker rm -f kobold-test
```

* Kill all Docker containers, images, and volumes
```
docker system prune --all --volumes
```

### Troubleshooting

* The following was used to test if all binaries and examples and packages specified could be installed.
```bash
cargo install --bins --examples --git=https://github.com/ltfschoen/kobold --branch=master --rev=2617dc3e4cff227d68e8a7ae883d8aa7cec6de6f kobold_counter_example kobold_csv_editor_example kobold_hello_world_example kobold_interval_example kobold_list_example kobold_qrcode_example kobold_stateful_example kobold_todomvc_example --verbose
```
However the Cargo.toml file was updated as follows instead so it would run without error with `trunk serve`
```
[dependencies]
# https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html#multiple-locations
kobold = { version = "0.5.0", git = "https://github.com/ltfschoen/kobold.git", rev = "d56e8f69d7678040c63d57e93f78d4c3aa35656d" }
kobold_macros = { version = "0.5.0", git = "https://github.com/ltfschoen/kobold.git", rev = "d56e8f69d7678040c63d57e93f78d4c3aa35656d" }
kobold_qr = { version = "0.5.0", git = "https://github.com/ltfschoen/kobold.git", rev = "d56e8f69d7678040c63d57e93f78d4c3aa35656d" }
```

* rust-toolchain file
    * It still isn't possible to install the toolchain and components specified in a rust-toolchain.toml file because. See
        * https://github.com/rust-lang/rustup/issues/2686
        * https://github.com/actions-rust-lang/setup-rust-toolchain/blob/main/action.yml#L11
        * https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file
