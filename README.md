### Log

* Install Rust https://doc.rust-lang.org/cargo/getting-started/installation.html
* Update Rust
    ```bash
    rustup update
    ```
* Install Kobold dependencies https://github.com/maciejhirsz/kobold#more-examples
    ```bash
    rustup target add wasm32-unknown-unknown
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
* Install [Trunk](https://trunkrs.dev/#getting-started)
* Create Trunk.toml & Paste:
```bash
[tools]
wasm_bindgen = "0.2.84"
```
* Run website
```bash
trunk serve
```
