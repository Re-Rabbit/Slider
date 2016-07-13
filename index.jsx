// -*- mode: js -*-

import React, { Component } from 'react'

export default class Slider extends Component {
    render() {
	return (
	  <div className="slider">
	    <div className="slider__line">
	      <div className="slider__cursor"></div>
	      <div className="slider__fill"></div>
	    </div>
	  </div>
	)
    }
}
