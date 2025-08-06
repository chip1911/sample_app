// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'
import 'custom/menu'
import 'custom/image_upload'
import 'custom/translations'

document.addEventListener("turbo:load", () => {
  I18n.locale = document.documentElement.lang || "en";
  console.log("Locale updated:", I18n.locale);
});
