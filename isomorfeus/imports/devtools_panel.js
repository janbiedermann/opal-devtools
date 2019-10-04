// entry file for the browser environment
// import stylesheets here
import '../styles/application.css';

// import npm modules that are valid to use only in the browser
import * as Redux from 'redux';
global.Redux = Redux;
import React from 'react';
global.React = React;
import * as ReactRouter from 'react-router';
import * as ReactRouterDOM from 'react-router-dom';
global.ReactRouter = ReactRouter;
global.ReactRouterDOM = ReactRouterDOM;
import ReactDOM from 'react-dom';
global.ReactDOM = ReactDOM;
import { BrowserRouter, Link, NavLink, Route, Switch } from 'react-router-dom';
// global.History = History;
global.Router = BrowserRouter;
global.Link = Link;
global.NavLink = NavLink;
global.Route = Route;
global.Switch = Switch;

import * as Mui from '@material-ui/core'
import * as MuiStyles from '@material-ui/styles'
global.Mui = Mui;
global.MuiStyles = MuiStyles;
import MuiIconsMenu from '@material-ui/icons/Menu'
import MuiIconsChevronLeft from '@material-ui/icons/ChevronLeft'
global.MuiIcons = {
    Menu: MuiIconsMenu,
    ChevronLeft: MuiIconsChevronLeft
};

chrome.runtime.onConnect.addListener(function(port) {});
global.BackgroundConnection = chrome.runtime.connect({name: "opal-devtools-panel"});

import init_app from 'devtools_panel_loader.rb';
init_app();
Opal.load('devtools_panel_loader');


