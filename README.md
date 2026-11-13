<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT HEADER -->
<br />
<div align="center">
  <h3 align="center">Architects Of Intelligence</h3>

  <p align="center">
    A turn-based digital board game about building AI-powered cities, with a content pipeline designers can extend without touching code.
    <br />
    <a href="https://github.com/CarlinoCalogero/architect-of-intelligence-board-game"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://carlinocalogero.github.io">View Portfolio</a>
    &middot;
    <a href="https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/issues">Report Bug</a>
    &middot;
    <a href="https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#key-features">Key Features</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

**Architects Of Intelligence** is a turn-based digital board game and resource management strategy game developed in **Godot 4.6**. Players manage and expand technological municipal empires on an interactive 2D grid, competing as city mayors to develop advanced AI infrastructures while balancing critical urban utilities.

The core gameplay loop blends strategic city-building, economic simulation, and risk management across phased game turns: players construct foundational city structures, power plants, water treatment facilities, and evolving tiers of AI systems (Generative AI, Theory of Mind AI), while managing real-time economies of **Money**, **Electricity (MW)**, **Water (ML)**, and **Citizen populations**.

Turns progress through structured setup and harvest phases where dynamic mathematical resource formulas and physical dice rolls calculate resource yields, maintenance costs, and population shifts, supported by interactive knowledge card decks and complex player trading systems.

### Project Context
* **Developer**: Solo Gameplay Programmer & System Architect (Calogero Carlino)
* **Context**: University of L'Aquila
* **Timeline**: 2025 – Present
* **Platform**: Windows

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Godot Engine][GodotEngine]][Godot-url]
* [![GDScript][GDScript-badge]][GDScript-url]
* [![Windows][Windows-badge]][Windows-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Key Features

**Data-Driven Runtime Content Pipeline**  
The engine decouples gameplay logic from content through `GameDefinition`, which scans and dynamically hydrates custom `.tres` resources at boot using Godot's `DirAccess` API. Designers can introduce or rebalance structures, cards, economic currencies, and player palettes without editing code or recompiling.

**Decoupled State Authority & Turn Machine**  
State ownership is partitioned under a centralized autoload (`GameManager`). `GameStateManager` maintains world state, player profiles, and cell occupancies, while `TurnManager` enforces a strict sequential state machine (`IDLE`, `HARVEST_RESOURCES`, `PLAYER_IS_CHOOSING_ACTION`) that processes automated harvest queues before transferring turn control.

**Interactive 2D Grid & Footprint Validation**  
Built on Godot's `TileMapLayer`, the placement system performs real-time coordinate transformations with dynamic color-coded bounding box previews (green for valid placement, red for blocked cells). Placements are checked against an $O(1)$ spatial lookup dictionary, while the `BuildUtility` dock continuously validates construction costs against live player ledgers.

**Formulaic Simulation, Dice & Peer Trading**  
Resource generation is calculated dynamically via `GameResourceFormula` and `HarvestAction`, factoring in structure multipliers, maintenance consumption, and physical dice rolls resolved through `DiceRollUtility`. Mayors interact through a 5-slot Knowledge Card hand and negotiate bilateral resource exchanges via a dedicated peer trading interface.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

* **Godot Engine 4.6** (Forward+ Renderer, Direct3D 12 support)  
  Download Godot Engine from [godotengine.org](https://godotengine.org/download)
* **Git**  
  Download Git from [git-scm.com](https://git-scm.com/)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/CarlinoCalogero/architect-of-intelligence-board-game.git
   ```
2. Open **Godot Engine**.
3. In the Project Manager, click **Import**.
4. Browse to the cloned directory and select the `project.godot` file.
5. Click **Import & Edit** to open the project.
6. Press **F5** (or click the **Play** button in the top-right corner) to run the game.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Gameplay Flow
1. **Setup Phase**: Players take initial turns founding their starter city and establishing baseline utilities.
2. **Harvest Phase**: At the start of each turn, structure yields are calculated dynamically. The active player rolls dice to resolve variable harvests and utility maintenance costs.
3. **Action Phase**: Mayors can:
   - **Build**: Select structures from the bottom dock (power plants, water facilities, AI tiers) and place them on valid grid tiles.
   - **Play Cards**: Activate drawn Knowledge Cards to gain municipal advantages.
   - **Trade**: Propose bilateral resource/card trades with rival mayors.

### Designer Content Pipeline
To introduce new structures, resources, or cards without touching GDScript:
1. Navigate to the appropriate subfolder inside `res://definitions/` (e.g., `structure_resources/`, `game_resources/`, `knowledge_cards/`).
2. Duplicate or create a new Godot `.tres` resource matching the corresponding domain definition (`StructureResource`, `GameResource`, etc.).
3. Configure the resource properties in the Godot Inspector.
4. Launch the game — `GameDefinition` automatically scans the directory and registers the new content at boot.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

This project is a personal academic and portfolio project. At this time, **outside contributions and pull requests are not accepted**.

If you encounter any bugs or have feedback, feel free to open an issue in the [Issues tab](https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/issues).

### Top contributors:

<a href="https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=CarlinoCalogero/architect-of-intelligence-board-game" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

**Calogero Carlino** - Solo Gameplay Programmer & System Architect  
* Email: [carlinocalogero.dev@gmail.com](mailto:carlinocalogero.dev@gmail.com)
* LinkedIn: [https://www.linkedin.com/in/calogero-carlino-2a94a33b5/](https://www.linkedin.com/in/calogero-carlino-2a94a33b5/)
* Portfolio: [https://carlinocalogero.github.io](https://carlinocalogero.github.io)
* GitHub: [@CarlinoCalogero](https://github.com/CarlinoCalogero)

Project Link: [https://github.com/CarlinoCalogero/architect-of-intelligence-board-game](https://github.com/CarlinoCalogero/architect-of-intelligence-board-game)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [University of L'Aquila](https://www.univaq.it/)
* [Godot Engine](https://godotengine.org/)
* [Jolt Physics](https://github.com/jrouwe/JoltPhysics)
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
* [Shields.io](https://shields.io/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/CarlinoCalogero/architect-of-intelligence-board-game.svg?style=for-the-badge
[contributors-url]: https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/CarlinoCalogero/architect-of-intelligence-board-game.svg?style=for-the-badge
[forks-url]: https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/network/members
[stars-shield]: https://img.shields.io/github/stars/CarlinoCalogero/architect-of-intelligence-board-game.svg?style=for-the-badge
[stars-url]: https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/stargazers
[issues-shield]: https://img.shields.io/github/issues/CarlinoCalogero/architect-of-intelligence-board-game.svg?style=for-the-badge
[issues-url]: https://github.com/CarlinoCalogero/architect-of-intelligence-board-game/issues
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/calogero-carlino-2a94a33b5/
[GodotEngine]: https://img.shields.io/badge/Godot%204.6-%23478CBF.svg?style=for-the-badge&logo=godot-engine&logoColor=white
[Godot-url]: https://godotengine.org/
[GDScript-badge]: https://img.shields.io/badge/GDScript-%23478CBF.svg?style=for-the-badge&logo=godot-engine&logoColor=white
[GDScript-url]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
[Windows-badge]: https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white
[Windows-url]: https://www.microsoft.com/windows
