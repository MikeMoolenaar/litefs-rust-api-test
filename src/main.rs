use axum::{
    response::{Html, IntoResponse},
    routing::get,
    Router,
};
use dotenv::dotenv;
use minijinja::{context, path_loader, Environment};
use serde::Serialize;
use sqlx::{migrate::MigrateDatabase, Pool, Sqlite, SqlitePool};
use std::{
    env,
    net::SocketAddr,
    sync::OnceLock,
    time::{Duration, Instant},
};

use tower_livereload::LiveReloadLayer;

static SHARED_JINJA_ENV: OnceLock<Environment> = OnceLock::new();
static SHARED_DB_POOL: OnceLock<Pool<Sqlite>> = OnceLock::new();

#[derive(sqlx::FromRow, Serialize)]
struct User {
    id: i64,
    email: String,
    name: String,
    hair_color: String,
    created_at: i64,
}

async fn index() -> impl IntoResponse {
    let template = SHARED_JINJA_ENV
        .get()
        .unwrap()
        .get_template("index.html")
        .unwrap();
    let now = Instant::now();
    let users = sqlx::query_as!(User, "SELECT * FROM users")
        .fetch_all(SHARED_DB_POOL.get().unwrap())
        .await
        .unwrap();
    let elapsed = format!("{:?}", now.elapsed());

    let rendered = template.render(context!(users, elapsed)).unwrap();
    return Html(rendered).into_response();
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    // Connect to DB
    // Connect to DB
    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    Sqlite::database_exists(&db_url)
        .await
        .expect("Database should exist, run `cargo sqlx database setup`");
    let db_pool = SqlitePool::connect(&db_url)
        .await
        .expect("Database should connect");
    sqlx::migrate!("./migrations")
        .run(&db_pool.clone())
        .await
        .unwrap();
    let _ = SHARED_DB_POOL.set(db_pool);

    // Setup templating
    let mut jinja = Environment::new();
    jinja.set_loader(path_loader("templates"));
    let _ = SHARED_JINJA_ENV.set(jinja);

    // Setup static file service
    // let static_dir_dist = ServeDir::new("static/dist");
    // let static_dit_dist_service = ServiceBuilder::new()
    //     .layer(SetResponseHeaderLayer::if_not_present(
    //         header::CACHE_CONTROL,
    //         HeaderValue::from_static("public, max-age=31536000, immutable"),
    //     ))
    //     .service(static_dir_dist);
    // let static_dir = ServeDir::new("static").append_index_html_on_directories(true);
    //

    // Setup router
    let mut app = Router::new().route("/", get(index));

    if cfg!(debug_assertions) {
        app = app.layer(LiveReloadLayer::new().reload_interval(Duration::from_millis(100)))
    }

    println!("Server is running at http://localhost:8081");

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8081").await.unwrap();
    axum::serve(
        listener,
        app.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await
    .unwrap();
}
