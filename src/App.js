import Header from "./components/Header/Header";
import React from 'react';
import "./app.scss";
import Footer from "./components/Footer/Footer";
import AccContainer from "./components/AccContainer/AccContainer";
import CTA from "./components/CTA/CTA";
import Cities from "./components/Cities/Cities";
import Collection from "./components/Collections/Collection";
import Card from "./components/Card/Card";

function App() {
  return (
    <div className="App">
      <Header />
      <Card />
      <Collection />
      <Cities />
      <CTA />
      <AccContainer />
      <Footer />
    </div>
  );
}

export default App;