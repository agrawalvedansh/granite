import React from "react";

import classnames from "classnames";
import { Link, useLocation } from "react-router-dom";

import { getFromLocalStorage } from "utils/storage";

import GraniteLogo from "./GraniteLogo";

const NavBar = () => {
  const userName = getFromLocalStorage("authUserName");
  const location = useLocation();

  return (
    <header className="bg-primary-white sticky top-0 z-20 w-full border-b border-gray-200 transition-all duration-500">
      <div className="mx-auto max-w-6xl px-6">
        <div className="flex h-16 items-center justify-between">
          <div className="w-max flex-shrink-0">
            <Link className="h-full w-auto" to="/dashboard">
              <GraniteLogo className="h-8 w-auto" />
            </Link>
          </div>
          <div className="flex items-center gap-x-4">
            <Link
              to="/"
              className={classnames("text-sm font-medium text-gray-800", {
                "text-indigo-600": location.pathname === "/",
              })}
            >
              Todos
            </Link>
            <Link
              className="rounded-md bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 focus:shadow"
              to="/tasks/create"
            >
              Add new task
            </Link>
            <Link className="flex items-center gap-x-1 rounded-md bg-gray-200 px-4 py-2 text-sm font-medium text-gray-800 hover:bg-gray-300 focus:shadow">
              <span className="block">{userName}</span>
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
};

export default NavBar;
